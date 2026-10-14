#! /bin/zsh

# Run Annix in check mode
ansible-playbook playbooks/deploy.yml --check --diff
