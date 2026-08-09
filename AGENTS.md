# Repository Guidelines

## Project Structure & Module Organization

This is a Nix flake for NixOS hosts, an ISO, and deployment outputs.
`flake.nix` defines inputs and imports the module tree.

- `modules/hosts/<hostname>/` contains machine-specific configuration; use
  `default.nix` as the host entry point and keep hardware facts alongside it.
- `modules/features/` contains reusable configuration grouped by purpose:
  `desktop`, `hosting`, `nix`, `programs`, `services`, `shared`, and `system`.
- `modules/users/` defines users; `modules/lib/` holds shared integrations;
  `modules/outputs/` defines ISO, Colmena, deploy-rs, and helper outputs.
- `assets/` stores static wallpapers, themes, and images. `templates/flake/`
  is the default flake template.

## Build, Test, and Development Commands

Run `nix develop` for the pre-commit tooling. Use `nix flake check` before
submitting changes; it evaluates the flake and its checks. Format Nix files
with `alejandra .` (also enforced by the hook). Run `pre-commit run --all-files`
for the complete local validation set.

Build the output affected by a change rather than rebuilding every host. For
example:

```bash
nix build .#nixosConfigurations.able-archer.config.system.build.toplevel
nix build .#packages.x86_64-linux.iso-system
```

CI builds `able-archer`, `steadfast-dart`, `steadfast-defender`, and both ISO
architectures. Use `./install.sh <target-ip> <hostname>` only for intentional
machine provisioning; it invokes remote deployment.

## Coding Style & Naming Conventions

Write idiomatic Nix and preserve nearby style: two-space indentation, compact
attribute sets where readable, and one concern per feature module. Name files
with lowercase kebab-case (for example, `restic-server.nix`) and host folders
after the hostname. Let Alejandra format `.nix` files. Remove unused bindings
and imports; deadnix is enabled in the hooks. Do not hand-edit `flake.lock`
unless changing inputs deliberately.

## Testing Guidelines

There is no separate unit-test suite. Treat flake evaluation, pre-commit, and
the relevant `nix build` output as required verification. For changes to a
host, build that host; for ISO changes, build the matching architecture. Avoid
committing generated build results.

## Commit & Pull Request Guidelines

Use concise Conventional Commit-style subjects seen in history, such as
`feat: add service`, `fix: correct endpoint`, `chore: update flake`, or
`docs: clarify installation`. Keep each commit focused. Pull requests should
explain the configuration impact, list validation run, link related issues when
applicable, and include screenshots only for visible desktop or web UI changes.

## Secrets & Deployment Safety

Secrets are managed outside this repository through the `secrets` flake input
and sops-nix. Never commit keys, tokens, decrypted secrets, or local machine
state. Review deployment and disk changes carefully: a successful merge may be
promoted to the `deployed` branch and applied by comin.
