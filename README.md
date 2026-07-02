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
- [preservation](https://github.com/nix-community/preservation) - for an "erase your darlings" setup.

## Installation
1. Flash the NixOS graphical installer ISO onto a USB stick.
2. Boot the target machine with the USB stick.
3. On the target machine, run:
```
ip addr
sudo passwd root
```
4. On your source machine, run:
```
./gen-host-key.sh

# Rekey secrets if needed...

./install.sh <target-machine-ip> <hostname>

# Enter "root" password
```


## Project Structure
```
.
├── assets                     # profile picture, default wallpaper, etc.
├── flake.nix                  # imports everything in /modules
├── gen-host-key.sh
├── install.sh                 # script to bootstrap a machine with nixos-anywhere
├── modules
│   ├── features
│   │   ├── desktop            # desktop environments (e.g. niri)
│   │   ├── programs           # user programs (e.g. firefox)
│   │   ├── services           # system services (e.g. tailscale)
│   │   ├── shared             # config which every machine needs
│   │   └── system             # system configuration
│   ├── flake-parts.nix
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
├── README.md
├── secrets
└── ssh-keys.nix
```
