# Repository Guidelines

## Project Structure & Module Organization

This flake uses `flake-parts` and `import-tree`: `flake.nix` imports every
module beneath `modules/`. Flake-wide options and integration live in
`modules/flake-parts.nix` and `modules/options.nix`.

- `modules/hosts/<hostname>/` contains a host's `default.nix` and its hardware
  inventory (`hardware.nix` or `facter.json`). Shared host-family configuration
  is in `modules/hosts/*-base.nix`; `modules/hosts/README.md` maps hosts to
  their intended roles.
- `modules/features/` contains reusable NixOS and Home Manager modules, grouped
  into `desktop`, `hosting` (with `infra/` for shared hosting infrastructure),
  `nix`, `programs`, `services`, `shared`, and `system`.
- `modules/users/` defines Home Manager user profiles. `modules/lib/` exposes
  shared flake integrations, `modules/vm/` provides VM targets, and
  `modules/outputs/` defines Colmena, ISO, and shell-script outputs.
- `assets/` holds static desktop assets and themes; `templates/flake/` is the
  default flake template. Root-level `ssh-keys.nix` contains public SSH keys.

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

Do not add code comments. The user writes and maintains comments themselves.

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
