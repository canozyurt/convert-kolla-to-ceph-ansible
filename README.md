
# Convert from Kolla Ansible to Ceph Ansible

## How to run
These instructions assume that your ceph-ansible folder is already set up and you followed ceph-ansible docs before. Hence we start with cd command. Make sure you have have gone through checklist before you run the playbooks.

```bash
 # cd ceph-ansible
 # wget https://github.com/openstack/kolla-ansible/raw/train-em/ansible/library/kolla_docker.py -P library
 # wget https://raw.githubusercontent.com/canozyurt/migrate-kolla-to-ceph-ansible/master/migrate.yml
 # wget https://raw.githubusercontent.com/canozyurt/migrate-kolla-to-ceph-ansible/master/migrate-osds.yml
 # ansible-playbook migrate.yml
 # ansible-playbook migrate-osds.yml
```

migrate.yml migrates mon,mgr,mds,nfs,rgw services respectively.
migrate-osds.yml migrates osd services.

## Checklist

* Make sure that current ceph version is Nautilus and you are using stable-4.0 branch for ceph-ansible.
* Make sure that your ceph-ansible clone is not suffering from [this issue](https://github.com/ceph/ceph-ansible/issues/7417) and nfs role works fine.
* Inventory and all.yml is configured and ceph-ansible can deploy a healthy cluster with correct NIC bindings and desired ceph.conf.
* containerized_deployment in all.yml is set to true.
* generated_fsid in all.yml is set to false
* fsid in all.yml is filled with your current ceph fsid deployed with kolla.
* Docker package names are set to match with kolla settings.
* ntp_service_enabled is disabled (or enabled if you don't have one already)
* RGW ports may differ in both tools. If so, set rgw ports properly.
* RGW Keystone integration is present in rgws.yml

For example configuration, you can refer to [all.yml](/group_vars/all.yml), [rgws.yml](/group_vars/rgws.yml.sample) and [inventory](/inventory/vagrant)
    
## Test Environment

This is an automated dev environment for Ceph deployment tool conversion.
It deploys Openstack Train with Ceph on Vagrant, and tries to takeover deployed Ceph with ceph-ansible. Tested on Ubuntu 18.04. Vagrant deploys generic/ubuntu1804 boxes.

## Warning
Don't follow these instruction on production. This is meant to be a PoC, run on an ephemeral VM, to share experience. Don't let virtualenv fool you: It's there to clean up easily, not to protect your environment.

## Installation

Deploying Openstack

```bash
 # git clone https://github.com/canozyurt/migrate-kolla-to-ceph-ansible --recursive
 # sudo apt update
 # sudo apt install make -y
 # cd ./migrate-kolla-to-ceph-ansible
 # make install-dependencies
 # vagrant up
 # make
```

Convert to ceph-ansible

```bash
 # make migrate
 # make migrate-osds
```

Above commands run migrate.yml and migrate-osds.yml playbooks respectively.
185.199.110.133
