#! /bin/zsh

# Template and apply NixOS configuration on every inventory host
ansible-playbook playbooks/deploy.yml "$@"
