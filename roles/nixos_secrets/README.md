# nixos_secrets

Sets secret values in a [sops](https://github.com/getsops/sops)-encrypted file on a NixOS host (e.g. one read by [sops-nix](https://github.com/Mic92/sops-nix)'s `sops.defaultSopsFile`), reconciling each run against a declarative map - without ever writing plaintext secret values to disk, Ansible's stdout, or its logs.

This role **does not** manage `.sops.yaml` or age/PGP keys - the target file's directory must already have a `.sops.yaml` (or inherit one from a parent directory) with a `creation_rule` covering it, and the host must already have its age private key in place, so `sops` itself can resolve recipients and decrypt.

## Variables

| Variable | Default | Purpose |
|---|---|---|
| `annix_secrets_file` | `/etc/nixos/secrets.yaml` | The sops-encrypted file to reconcile |
| `annix_secrets` | `{}` | Map of secret name -> plaintext value, nestable to any depth (e.g. per-player secrets). Source this from an `ansible-vault`-encrypted var, never plain inventory |
| `annix_secrets_age_key_file` | `/var/lib/sops-nix/key.txt` | The host's age private key, used to decrypt `annix_secrets_file` for comparison/updates (sops-nix's own default `sops.age.keyFile`) |

Nested maps become sops attribute paths - `{violet: {nexusmods: "..."}}` sets `["violet"]["nexusmods"]`.

## Requirements

- The `sops` CLI must be on the target host's `PATH` (e.g. add `pkgs.sops` to `environment.systemPackages`).
- The target directory's `.sops.yaml` creation rules and the host's age key must already be set up; this role only sets values, not recipients.

## Example

```yaml
# group_vars/atlantis.yml (plaintext, safe to commit)
annix_secrets_file: /etc/nixos/secrets.yaml

# host_vars/atlantis/vault.yml (ansible-vault encrypted)
annix_secrets:
  violet:
    nexusmods: "..."
  rachel:
    romm: "..."
```

Each run decrypts and compares the current value of every key in `annix_secrets` before writing, so a repeat run with no changes is a no-op.
