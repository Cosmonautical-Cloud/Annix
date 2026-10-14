# Changelog

All notable changes to this project are documented here. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project follows [semantic versioning](https://semver.org/).

## [0.2.0] - 2026-10-13

### Added

- New `nixos_secrets` role: reconciles a declarative `annix_secrets` map (name -> plaintext value, meant to be sourced from an `ansible-vault`-encrypted var) into a sops-encrypted file on the target host, decrypting only in memory to compare before writing so a repeat run with nothing changed is a no-op. Never manages `.sops.yaml`/recipients or writes plaintext secret values to disk or Ansible's logs.
- `playbooks/deploy.yml` now also runs `nixos_secrets` (when `annix_secrets` is set) before templating/rebuilding, so secrets are in place before any rebuild that depends on them.

## [0.1.0] - 2026-10-13

### Added

- Initial release: the `nixos_config` role, templating any number of `.nix` files from inventory-defined YAML (via `cosmonautical.nixify.to_nix`) to a NixOS host's `/etc/nixos`, parse-validating each one first (`cosmonautical.nixify.nix_check`), and running `nixos-rebuild` — only when a templated file actually changed, unless `annix_force_rebuild` is set.
- Support for both classic NixOS channels (`annix_upgrade_channels`) and flakes (`annix_flake`, `annix_flake_path`, `annix_update_flake_lock`), and any `nixos-rebuild` action (`switch`, `boot`, `test`, `dry-build`, `build`).
- The `playbooks/deploy.yml` entry point plus `deploy.zsh`/`check.zsh` wrappers, matching Nomadintosh/Nomaduntu's conventions.
