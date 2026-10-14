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

This templates `/etc/nixos/configuration.nix` (parse-checked first via Nixify's `nix_check` module) and runs `nixos-rebuild switch` — but only when a templated file actually changed on that run, so a repeat run with no edits is a no-op. See the [`nixos_config` role's README](roles/nixos_config/README.md) for every variable, including flake support, channel upgrades, picking a different `nixos-rebuild` action (`boot`, `test`, `dry-build`, `build`), and templating more than one file (e.g. a flake's `flake.nix` alongside `configuration.nix`).

To also manage secrets in a sops-encrypted file (e.g. one read by [sops-nix](https://github.com/Mic92/sops-nix)), see the [`nixos_secrets` role's README](roles/nixos_secrets/README.md).

Preview changes without applying them:

```
./check.zsh
```

## License

GPL-3.0-only.
