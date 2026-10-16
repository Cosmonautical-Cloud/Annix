#! /bin/zsh

# This script runs the collection's Molecule scenarios (molecule/*/) in
# nixos/nix containers. Needs Docker, plus:
#   pip install molecule "molecule-plugins[docker]"
#   ansible-galaxy collection install community.docker
# Pass e.g. `-s flake` to run a single scenario instead of all of them.
if (( $# )); then
  molecule test "$@"
else
  molecule test --all
fi
