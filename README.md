
# Convert from Kolla Ansible to Ceph Ansible

This is an automated dev environment for Ceph deployment tool conversion.
It deploys Openstack Train with Ceph on Vagrant, and tries to takeover deployed Ceph with ceph-ansible.


## Warning
Don't run any of these files in the repository on production. This is meant to be a PoC, run on an ephemeral VM, to share experience. Don't let virtualenv fool you: It's there to clean up easily, not to protect your environment.
    
## Tested Environment

Tested on Ubuntu 18.04. Vagrant deploys generic/ubuntu1804 boxes.
## Installation

Deploying Openstack

```bash
 # git clone https://github.com/canozyurt/convert-kolla-to-ceph-ansible --recursive
 # sudo apt update
 # sudo apt install make -y
 # cd ./convert-kolla-to-ceph-ansible
 # make install-dependencies
 # vagrant up
 # make
```

Convert to ceph-ansible

```bash
 # make convert
 # make convert-osds
```

Above commands run convert.yml and conver.osds.yml playbooks respectively.
