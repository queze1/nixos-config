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
# not general use, assumes a lot
nix run .#install -- <target-machine-ip> <hostname> [nixos-facter path]

# configure secrets when prompted
```
5. For home servers:
  - If internet doesn't work, run `nmtui`.
  - Remove `services.getty.autologinUser = "root"` if you set it for convenience.

## Project Structure
flake-parts for flake outputs, every nixosConfiguration does an import-tree on /modules, uses my.* options to toggle modules.
```
.
├── flake.nix                      # imports everything in /outputs
├── assets                         # profile picture, default wallpaper, etc.
├── modules
│   ├── constants.nix
│   ├── deployment                 # deployment tooling (e.g. comin)
│   ├── desktop                    # desktop environment (e.g. niri)
│   ├── hosting                    # self-hosted applications & networking
│   │   ├── infra
│   │   ├── music
│   │   │   ├── default.nix
│   │   │   ├── ...
│   │   │   └── navidrome.nix
│   │   └── ...
│   ├── hosts                      # host configuration
│   │   ├── _hardware              # - hardware config
│   │   ├── able-archer.nix        # - personal machine (UTM VM)
│   │   ├── autumn-forge.nix       # - macos laptop
│   │   ├── mirage-[..].nix        # - vpses
│   │   ├── steadfast-[...].nix    # - home servers
│   ├── lib                        # helper libraries (e.g. home manager)
│   ├── nix                        # nix-related config (e.g. subsituters)
│   ├── profiles                   # host profiles (e.g. home server, vps)
│   ├── programs                   # user programs (e.g. firefox)
│   ├── services                   # services (e.g. openssh, tailscale)
│   ├── system                     # system config (e.g. boot, sound)
│   ├── users                      # user definitions
│   │   ├── commander.nix          # - server user
│   │   └── queze.nix              # - personal user
│   └── vm                         # workarounds for vms
│       └── utm.nix
├── npins                          # non-flake inputs (e.g. docker images)
├── outputs                        # flake outputs
│   ├── colmena.nix                # - machines managed by colmena
│   ├── hosts                      # - host definitions
│   ├── iso.nix                    # - custom iso images
│   └── ...
├── ssh-keys.nix                   # public ssh keys
└── templates                      # flake templates
```

## CI/CD
1. [nixbuild GitHub Action](https://github.com/queze1/nixos-config/blob/main/.github/workflows/nixbuild.yml) builds NixOS configurations on [nixbuild.net](https://nixbuild.net/). If the build succeeds, fast-forwards the `deployed` branch to `main`.
2. [comin](https://github.com/nlewo/comin/) pings the `deployed` branch, pulls and applies changes.
3. [colmena GitHub Action](https://github.com/queze1/nixos-config/blob/main/.github/workflows/colmena.yml) uses [colmena](https://github.com/nix-community/colmena) to remotely deploy configurations to weak hosts (such as VPSes) which cannot rebuild locally. It pushes built configurations to a self-hosted [Attic](https://github.com/zhaofengli/attic) binary cache.
4. On an automated flake update pull request, a [GitHub Action](https://github.com/queze1/nixos-config/blob/main/.github/workflows/build.yml) builds all NixOS configurations on GitHub runners and pushes the results to the binary cache.
