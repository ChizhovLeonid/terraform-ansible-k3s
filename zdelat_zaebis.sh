#!/bin/bash
(cd /terraform-ansible-k3s/terik/ && ./terraform apply -auto-approve)
(cd /terraform-ansible-k3s/ansible/ && ansible-playbook install_k3s.yml)
cat /terraform-ansible-k3s/terik/hosts_list | grep yoba_fett1
sed -i 's/default/terraform-ansible-k3s/g' ./k3s/terraform-ansible-k3s.yml
ip_yoba7 = `cat ./terik/hosts_list | grep yoba_fett7 | awk -F"=" '{print $2}'`
sed -i "s/127.0.0.1/$ip_yoba7/g" ./k3s/terraform-ansible-k3s.yml