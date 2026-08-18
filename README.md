# nixos-config

My personal NixOS config. I do things on my computer and self-host stuff.

Uptime tracker: [https://uptime.osipol.uk/](https://uptime.osipol.uk/)

## Software
- Window manager: [niri](https://github.com/niri-wm/niri)
- Desktop shell: [Noctalia Shell](https://github.com/noctalia-dev/noctalia)
- Editor: [Neovim](https://neovim.io/)
- Terminal: [foot](https://codeberg.org/dnkl/foot)
- Shell: [Fish](https://fishshell.com/)

## Features
- [sops-nix](https://github.com/Mic92/sops-nix) - To securely manage secrets.
- [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) - To remotely install NixOS with a single CLI command.
- [disko](https://github.com/nix-community/disko) - For declarative disk management.
- [preservation](https://github.com/nix-community/preservation) - For an ephemeral root setup.

## Installation
1. Build the custom ISO and burn it onto a USB with `nix run github:queze1/nixos-config#burn-iso-image`.
  - Don't do this unless you're me, as it's configured to allow SSH from my public key.
  - Alternatively, you can use an ISO from the [official website](https://nixos.org/download/).
2. Boot the target machine with the USB stick.
3. On the target machine, run:
```bash
nmtui # if using custom ISO
ip addr
```
4. On your source machine, run:
```bash
./install.sh <target-machine-ip> <hostname>

# configure secrets when prompted
```
5. For home servers:
  - If internet doesn't work, run `nmtui`.
  - Remove `services.getty.autologinUser = "root"` if you set it for convenience.

## Project Structure
```
.
├── assets                     # profile picture, default wallpaper, etc.
├── flake.nix                  # imports everything in /modules
├── install.sh                 # script to bootstrap a machine with nixos-anywhere
├── modules
│   ├── features               # nix modules which add features
│   │   ├── desktop            # - desktop environments (e.g. niri)
│   │   ├── hosting            # - self-hosted apps and infra
│   │   ├── nix                # - nix-related settings
│   │   ├── programs           # - user programs (e.g. firefox)
│   │   ├── services           # - system services (e.g. tailscale)
│   │   ├── shared             # - config which every machine needs
│   │   └── system             # - system configuration
│   ├── flake-parts.nix
│   ├── hosts                  # host definitions
│   │   ├── able-archer        # - personal machine
│   │   ├── steadfast-base     # - shared home server config
│   │   └── steadfast-[...]    # - home servers
│   ├── lib                    # helper libraries
│   ├── options.nix            # shared options
│   ├── outputs                # flake outputs
│   │   ├── iso.nix            # - custom ISO images
│   │   ├── colmena.nix        # - machines managed by colmena
│   │   └── ...
│   ├── users                  # user definitions
│   │   ├── commander.nix
│   │   └── queze.nix
│   └── vm                     # workarounds for VMs
└── README.md
```

## CI/CD
1. [nixbuild GitHub Action](https://github.com/queze1/nixos-config/blob/main/.github/workflows/nixbuild.yml) builds NixOS configurations on [nixbuild.net](https://nixbuild.net/). If the build succeeds, fast-forwards the `deployed` branch to `main`.
2. [comin](https://github.com/nlewo/comin/) pings the `deployed` branch, pulls and applies changes.
3. [colmena GitHub Action](https://github.com/queze1/nixos-config/blob/main/.github/workflows/colmena.yml) uses [colmena](https://github.com/nix-community/colmena) to remotely deploy configurations to weak hosts (such as VPSes) which cannot rebuild locally. It pushes built configurations to a self-hosted [Attic](https://github.com/zhaofengli/attic) binary cache.
4. On a pull request (usually an automated update), a [GitHub Action](https://github.com/queze1/nixos-config/blob/main/.github/workflows/build.yml) builds all NixOS configurations on GitHub runners and pushes the results to the binary cache.

