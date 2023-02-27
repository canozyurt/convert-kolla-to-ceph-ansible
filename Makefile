VENV := ${PWD}/.venv
BIN := $(VENV)/bin
PYTHON := $(BIN)/python
PIP := $(BIN)/pip

APT_PACKAGES := \
	docker.io \
	docker-compose \
	qemu-kvm \
	qemu-utils \
	libvirt-bin \
	python-virtualenv \
	python-dev \
	libffi-dev \
	gcc \
	libssl-dev \
	python-selinux \
	python-setuptools \
	vagrant-libvirt

define KOLLA_ANSIBLE_CMDS
	bootstrap-servers \
	prechecks \
	deploy \
	post-deploy \
	pull
endef

CEPH_ANSIBLE_ENVS := ANSIBLE_LIBRARY=${PWD}/ceph-ansible/library ANSIBLE_ACTION_PLUGINS=${PWD}/ceph-ansible/plugins/actions

all: prepare bootstrap-servers prechecks deploy

$(VENV):
	python -m virtualenv $@
	$(PIP) install -U pip
	$(PIP) install -U setuptools

prepare: install-dependencies registry
	$(BIN)/ansible-playbook -i inventory/ prepare.yml

$(KOLLA_ANSIBLE_CMDS): kolla-ansible/tools/kolla-ansible $(BIN)/kolla-ansible
	PATH="$(BIN):${PATH}" kolla-ansible/tools/kolla-ansible --configdir ${PWD}/group_vars -i inventory/ $@

migrate migrate-osds: ceph-ansible/library/kolla_docker.py roles
	$(CEPH_ANSIBLE_ENVS) $(BIN)/ansible-playbook -i inventory/ $@.yml

install-dependencies: install-apt-packages $(VENV) install-pip-packages

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

$(BIN)/kolla-ansible: kolla-ansible/setup.cfg kolla-ansible/setup.py
	cd kolla-ansible; $(PYTHON) setup.py install
