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
```bash
.
├── home
│   └── modules
│       ├── desktop
│       ├── programs
├── hosts
│   ├── utm-vm
│   ├── utm-vm-2
│   └── vmware-vm
├── secrets
├── system
│   ├── common
│   ├── core
│   ├── disko
│   └── vm
└── users
    └── queze.nix
```
