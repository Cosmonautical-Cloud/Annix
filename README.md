# Annix

An Ansible collection for deploying and managing NixOS hosts' configuration: define a host's `configuration.nix` as plain YAML in your Ansible Automation Platform inventory, template it to `/etc/nixos`, and run `nixos-rebuild`.

## How it fits together

- **[Nixify](https://github.com/Cosmonautical-Cloud/Nixify)** (`cosmonautical.nixify`) converts that YAML into Nix expression text — Annix depends on it rather than reimplementing the conversion.
- **Annix** (this collection) is the NixOS-specific half: it owns `/etc/nixos`, validation, and when/how `nixos-rebuild` actually runs.

## Requirements

- Ansible installed on the control machine
- A NixOS target host, reachable over SSH, with a user able to `become: true`
- Ansible collections:
  ```
  ansible-galaxy collection install -r collections/requirements.yml
  ```

## Usage

Define your host's configuration as nested YAML in inventory (see [inventory/hosts.example.yml](inventory/hosts.example.yml)):

```yaml
violet-nixos.example.com:
  annix_nixos_config:
    imports:
      __nix_raw__: "[ ./hardware-configuration.nix ]"
    networking:
      hostName: violet-nixos
      firewall:
        enable: true
    services:
      openssh:
        enable: true
    system:
      stateVersion: "24.05"
```

Then run:

```
./deploy.zsh
```

This templates `/etc/nixos/configuration.nix` (parse-checked first via Nixify's `nix_check` module) and runs `nixos-rebuild switch` — but only when a templated file actually changed on that run, so a repeat run with no edits is a no-op. See the [`nixos_config` role's README](roles/nixos_config/README.md) for every variable, including flake support, channel upgrades, and picking a different `nixos-rebuild` action (`boot`, `test`, `dry-build`, `build`).

Preview changes without applying them:

```
./check.zsh
```

## Testing

`./lint.zsh` runs ansible-lint. `./molecule.zsh` runs the [Molecule](https://ansible.readthedocs.io/projects/molecule/) scenarios, which apply the `nixos_config` role inside a `nixos/nix` container (real Nix for parse-checking, a stub `nixos-rebuild` that records how it was called):

- `default` — channel mode: `configuration.nix` from `annix_nixos_config`, `--upgrade`, a non-default action and extra args, plus a config that fails validation and must never be written.
- `flake` — flake mode: several files via `annix_nixos_files`, `flake.nix` with no function header, `--flake`.

Both check that a second run changes nothing and doesn't rebuild again. They need Docker locally (`pip install molecule "molecule-plugins[docker]"` and `ansible-galaxy collection install community.docker`); CI runs them on every PR.

## License

GPL-3.0-only.
