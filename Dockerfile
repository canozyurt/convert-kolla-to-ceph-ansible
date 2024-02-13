FROM ubuntu:18.04

WORKDIR /app

RUN apt update && apt install git python-pip wget -y

RUN git clone https://github.com/ceph/ceph-ansible.git -b stable-4.0

WORKDIR /app/ceph-ansible

#Latest versions in requirements.yml threw pip errors, manually installing old versions
RUN pip install 'ansible<2.9.27' 'netaddr<0.9' 'six<1.17.0'

RUN wget https://github.com/openstack/kolla-ansible/raw/train-em/ansible/library/kolla_docker.py -P /app/ceph-ansible/library

#NFS ganesha.pid fix
RUN wget https://github.com/ceph/ceph-ansible/commit/45ddbedef2ffdee04f35ea90f01a6ea49181cdf5.diff && git apply 45ddbedef2ffdee04f35ea90f01a6ea49181cdf5.diff

COPY migrate* ./

ENTRYPOINT ["/bin/bash"]
