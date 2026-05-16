# nixos-config

My personal NixOS config.

## Software
- Window manager: [niri](https://github.com/YaLTeR/niri)
- Desktop shell: [Noctalia Shell](https://github.com/noctalia-dev/noctalia-shell)
- Editor: [Neovim](https://neovim.io/)
- Terminal: [foot](https://codeberg.org/dnkl/foot)
- Shell: [Fish](https://fishshell.com/)

## Features
- [agentix](https://github.com/ryantm/agenix) - to securely manage secrets
- [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) - to remotely install NixOS with a single CLI command
- [disko](https://github.com/nix-community/disko) - for declarative disk management

## Project Structure
TBD

NOTE: All Home Manager modules are imported with home-manager.sharedModules so NixOS modules can import Home Manager modules without knowing about users. This means that all users will have the same Home Manager configuration.
This could be changed if instead, there was a collector NixOS module which only imported NixOS modules which also import helper Home Manager modules, and a separate Home Manager collector which individual users import.

