# nixos-config

My personal NixOS config.

## Software
- Window manager: [niri](https://github.com/YaLTeR/niri)
- Desktop shell: [Noctalia Shell](https://github.com/noctalia-dev/noctalia-shell)
- Editor: [Neovim](https://neovim.io/)
- Terminal: [foot](https://codeberg.org/dnkl/foot)
- Shell: [Fish](https://fishshell.com/)

## Features
- [sops-nix](https://github.com/Mic92/sops-nix) - to securely manage secrets
- [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) - to remotely install NixOS with a single CLI command
- [disko](https://github.com/nix-community/disko) - for declarative disk management
- [preservation](https://github.com/nix-community/preservation) - for an ephemeral root setup.

## Installation
1. Build the custom ISO with `nix build .#iso-x86` (or `.#iso-aarch64`)
  - Don't do this unless you're me, as it's configured to allow SSH from my public key.
2. Burn the ISO into a USB stick.
3. Boot the target machine with the USB stick.
4. On the target machine, run:
```
ip addr
```
5. On your source machine, run:
```
./install.sh <target-machine-ip> <hostname>

# configure secrets
```
5. For home servers:
  - Manually fix problems by physically logging in with "root" user and "root" password.
  - If internet doesn't work, run `nmcli dev wifi connect <SSID> password <PASSWORD>`.
  - Once SSH works, run `passwd -l root` to lock the root account.

## Project Structure
```
.
├── assets                     # profile picture, default wallpaper, etc.
├── flake.nix                  # imports everything in /modules
├── install.sh                 # script to bootstrap a machine with nixos-anywhere
├── modules
│   ├── features
│   │   ├── desktop            # desktop environments (e.g. niri)
│   │   ├── hosting            # self-hosted apps and infra
│   │   ├── programs           # user programs (e.g. firefox)
│   │   ├── services           # system services (e.g. tailscale)
│   │   ├── shared             # config which every machine needs
│   │   └── system             # system configuration
│   ├── flake-parts.nix
│   ├── iso.nix                # custom ISO images
│   ├── hosts                  # host definitions
│   │   ├── able-archer        # - personal machine
│   │   ├── steadfast-base     # - shared home server config
│   │   ├── steadfast-[...]    # - home servers
│   ├── lib                    # helper libraries
│   ├── options.nix            # shared options
│   ├── users                  # user definitions
│   │   ├── commander.nix
│   │   └── queze.nix
│   └── vm                     # workarounds for VMs
└── README.md
```
