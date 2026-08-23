# Repository Guidelines

## Project Structure & Module Organization

This flake uses `flake-parts` and `import-tree`. `flake.nix` imports every
module beneath `outputs/`; the NixOS system factory in `outputs/hosts/default.nix`
imports the shared modules beneath `modules/`.

- `outputs/` defines flake-level configuration and outputs: `flake-parts.nix`,
  deployment output (`colmena.nix`), installer output (`iso.nix`), shell
  scripts, and the current host configurations in `outputs/hosts/`. Host
  directories contain a `default.nix` and, where needed, a `hardware.nix`;
  host-family bases live alongside them as `*-base.nix`.
- `modules/` contains reusable NixOS and Home Manager modules. Group modules by
  concern: `desktop/`, `hosting/` (including `infra/` and `music/`), `nix/`,
  `programs/` (including nested program modules such as `nvf/`), `services/`,
  and `system/`. `modules/users/` defines Home Manager user profiles;
  `modules/lib/` exposes shared integrations; `modules/deployment/` contains
  deployment-related modules; `modules/vm/` provides VM targets; and
  `constants.nix` contains shared constants.
- `assets/` holds static desktop assets and themes; `templates/flake/` is the
  default flake template. Root-level `ssh-keys.nix` contains public SSH keys.

The repository is in the middle of a migration. Treat the current
`outputs/hosts/` layout as transitional: migrate reusable configuration into
`modules/` when working in the affected area. The intended final state is for
`outputs/` to contain only flake outputs, while host and reusable configuration
lives under `modules/`.

## Reference tools

Use the NixOS MCP server as the primary reference for NixOS, Home Manager, nix-darwin options, packages, modules, versions, and flakes. Do not rely on training data when an MCP lookup can answer the question.

| Purpose                | Tools                                                                                                                    |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| NixOS options/packages | `mcp__nixos__nixos_search`, `mcp__nixos__nixos_info`                                                                     |
| Home Manager options   | `mcp__nixos__home_manager_search`, `mcp__nixos__home_manager_options_by_prefix`, `mcp__nixos__home_manager_list_options` |
| nix-darwin options     | `mcp__nixos__darwin_search`, `mcp__nixos__darwin_options_by_prefix`, `mcp__nixos__darwin_list_options`                   |
| Package versions       | `mcp__nixos__nixhub_package_versions`, `mcp__nixos__nixhub_find_version`                                                 |
| Flake search           | `mcp__nixos__nixos_flakes_search`                                                                                        |


## Coding Style & Naming Conventions

Write idiomatic Nix and preserve nearby style: two-space indentation, compact
attribute sets where readable, and one concern per feature module. Name files
with lowercase kebab-case (for example, `restic-server.nix`) and host folders
after the hostname. Let Alejandra format `.nix` files. Remove unused bindings
and imports; deadnix is enabled in the hooks. Do not hand-edit `flake.lock`
unless changing inputs deliberately.

Do not add new code comments. The user writes and maintains comments themselves. When migrating code, keep any existing comments.

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
