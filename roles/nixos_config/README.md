# nixos_config

Templates one or more `.nix` files from Ansible inventory data (via [`cosmonautical.nixify`](https://github.com/Cosmonautical-Cloud/Nixify)) into a NixOS host's `/etc/nixos`, then runs `nixos-rebuild` — but only when a templated file actually changed, so a run that touches nothing is a no-op. It can also garbage-collect old system generations afterwards (opt-in).

## Variables

| Variable | Default | Purpose |
|---|---|---|
| `annix_nixos_config_dir` | `/etc/nixos` | Where files are written |
| `annix_nixos_config` | `{}` | The `configuration.nix` attrset body, as nested YAML |
| `annix_nixos_files` | `{configuration.nix: annix_nixos_config}` | Override to template more than one file in the same run |
| `annix_nixos_function_args` | `{ config, pkgs, lib, ... }` | Default function header, applied to every file in `annix_nixos_files` |
| `annix_nixos_file_function_args` | `{}` | Per-file header override, keyed by filename - set a file to `""` for a bare attrset with no header (e.g. `flake.nix`) |
| `annix_validate` | `true` | Parse-check every rendered file (`nix-instantiate --parse`) before writing it |
| `annix_rebuild` | `true` | Whether to run `nixos-rebuild` at all after templating |
| `annix_rebuild_action` | `switch` | `switch`, `boot`, `test`, `dry-build` or `build` |
| `annix_flake` | `false` | Use a flake-based configuration instead of channels |
| `annix_flake_path` | `""` | Flake reference, e.g. `/etc/nixos#violet-nixos` — required when `annix_flake` is `true` |
| `annix_update_flake_lock` | `false` | Run `nix flake update` first (opt-in — changes input versions, not just config) |
| `annix_upgrade_channels` | `false` | Pass `--upgrade` to `nixos-rebuild` (opt-in, channel mode only) |
| `annix_rebuild_extra_args` | `[]` | Extra CLI args appended verbatim |
| `annix_force_rebuild` | `false` | Rebuild even when no templated file changed (e.g. after a channel/flake-input update) |
| `annix_gc_enabled` | `false` | Garbage-collect after templating/rebuilding (opt-in — pruned generations can't be rolled back to) |
| `annix_gc_keep` | `10` | System generations to keep when `annix_gc_enabled` is `true`; `0` or `null` keeps them all |

## Garbage collection

With `annix_gc_enabled: true`, every run ends (after any rebuild, so its new generation counts) by deleting all but the last `annix_gc_keep` generations of the system profile (`nix-env --delete-generations +N`) and then running `nix-collect-garbage` to free the store paths nothing references any more. The current generation is always kept, even after a rollback. Setting `annix_gc_keep` to `0` or `null` skips the generation pruning, so only paths that no generation uses are collected. Both steps report `changed` only when they actually deleted something.

## Example

```yaml
annix_nixos_config:
  imports:
    __nix_raw__: "[ ./hardware-configuration.nix ]"
  networking:
    hostName: violet-nixos
  services:
    openssh:
      enable: true
  system:
    stateVersion: "24.05"
```

See [Nixify's README](https://github.com/Cosmonautical-Cloud/Nixify#readme) for how YAML data maps to Nix syntax, and how to emit literal Nix expressions (like the `imports` line above) instead of quoted strings.
