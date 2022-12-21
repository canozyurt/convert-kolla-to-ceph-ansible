VENV := .venv
BIN := $(VENV)/bin
PYTHON := $(BIN)/python
PIP := $(BIN)/pip

APT_PACKAGES := \
	docker.io \
	docker-compose \
	qemu-kvm \
	libvirt-bin \
	python-virtualenv \
	python-dev \
	libffi-dev \
	gcc \
	libssl-dev \
	python-selinux \
	python-setuptools

define KOLLA_ANSIBLE_CMDS
	bootstrap-servers \
	prechecks \
	deploy
endef

CEPH_ANSIBLE_ENVS := ANSIBLE_LIBRARY=${PWD}/ceph-ansible/library ANSIBLE_ACTION_PLUGINS=${PWD}/ceph-ansible/plugins/actions

all: prepare bootstrap-servers prechecks deploy

$(VENV):
	python -m virtualenv $@
	$(PIP) install -U pip
	$(PIP) install -U setuptools

prepare: install-dependencies registry
	$(BIN)/ansible-playbook -i inventory/ prepare.yml

$(KOLLA_ANSIBLE_CMDS): kolla-ansible/tools/kolla-ansible
	PATH="$(BIN):${PATH}" kolla-ansible/tools/kolla-ansible --configdir ${PWD}/group_vars -i inventory/ $@

convert convert-osds: ceph-ansible/library/kolla_docker.py roles
	$(CEPH_ANSIBLE_ENVS) $(BIN)/ansible-playbook -i inventory/ $@.yml


install-dependencies: install-apt-packages $(VENV) install-pip-packages $(BIN)/kolla-ansible

install-apt-packages:
	sudo DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y $(APT_PACKAGES)

install-pip-packages: kolla-ansible/requirements.txt ceph-ansible/requirements.txt
	for txt in $^; do $(PIP) install -r $$txt; done

registry: /usr/bin/docker
	sudo docker-compose up -d

ceph-ansible/library/kolla_docker.py: kolla-ansible/ansible/library/kolla_docker.py
	cp $^ $@

roles: ceph-ansible/roles
	ln -s $^	
