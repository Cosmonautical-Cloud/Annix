# Changelog

All notable changes to this project are documented here. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project follows [semantic versioning](https://semver.org/).

## [0.2.0] - 2026-10-13

### Added

- `annix_nixos_file_function_args`: per-file override of each templated file's function header, keyed by the same filenames used in `annix_nixos_files`. Falls back to `annix_nixos_function_args` when a file isn't listed, and an empty string renders a bare attrset with no header at all - needed for files like `flake.nix` whose top level isn't a NixOS module function.

## [0.1.0] - 2026-10-13

### Added

- Initial release: the `nixos_config` role, templating any number of `.nix` files from inventory-defined YAML (via `cosmonautical.nixify.to_nix`) to a NixOS host's `/etc/nixos`, parse-validating each one first (`cosmonautical.nixify.nix_check`), and running `nixos-rebuild` — only when a templated file actually changed, unless `annix_force_rebuild` is set.
- Support for both classic NixOS channels (`annix_upgrade_channels`) and flakes (`annix_flake`, `annix_flake_path`, `annix_update_flake_lock`), and any `nixos-rebuild` action (`switch`, `boot`, `test`, `dry-build`, `build`).
- The `playbooks/deploy.yml` entry point plus `deploy.zsh`/`check.zsh` wrappers, matching Nomadintosh/Nomaduntu's conventions.
