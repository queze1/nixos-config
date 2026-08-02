{inputs, ...}: {
  # Simple filesystem, no swap
  flake.factory.diskoSimpleEfi = {device}: {
    imports = [inputs.disko.nixosModules.default];

    disko.devices.disk.main = {
      device = device;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "500M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              extraArgs = [
                "-L"
                "nixos"
              ];
            };
          };
        };
      };
    };
  };

  # Mostly copied from https://www.vimjoyer.com/vid89-impermanent/disko
  flake.factory.diskoTmpfsOnRoot = {device}: {
    imports = [inputs.disko.nixosModules.default];

    fileSystems."/nix".neededForBoot = true;
    fileSystems."/persistent".neededForBoot = true;

    disko.devices.nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=25%"
          "mode=755"
        ];
      };
    };

    disko.devices.disk.main = {
      device = device;
      type = "disk";
      content.type = "gpt";

      content.partitions.boot = {
        name = "boot";
        size = "1M";
        type = "EF02";
      };

      content.partitions.esp = {
        name = "ESP";
        size = "1G";
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
        };
      };

      content.partitions.swap = {
        size = "4G";
        content = {
          type = "swap";
        };
      };

      content.partitions.root = {
        name = "root";
        size = "100%";
        content = {
          type = "btrfs";
          extraArgs = [
            "-f"
            "-L"
            "nixos"
          ];
          subvolumes = {
            "/persistent" = {
              mountOptions = [
                "subvol=persistent"
                "noatime"
              ];
              mountpoint = "/persistent";
            };
            "/nix" = {
              mountOptions = [
                "subvol=nix"
                "noatime"
              ];
              mountpoint = "/nix";
            };
          };
        };
      };
    };
  };

  flake.factory.diskoBrtfsEphemeralRoot = {device}: {pkgs, ...}: let
    # Number of root backups to keep
    rootBackupLimit = 10;
  in {
    imports = [inputs.disko.nixosModules.default];

    fileSystems."/nix".neededForBoot = true;
    fileSystems."/persistent".neededForBoot = true;

    boot.initrd.systemd.services.reset-root = {
      description = "Backup root subvolume and initialise a new root";
      wantedBy = ["initrd.target"];
      after = [
        "local-fs-pre.target" # when filesystems are ready for mounting
        "initrd-root-device.target" # when the root filesystem device is avaliable but before it's mounted
      ];
      before = ["sysroot.mount"]; # mounts the root filesystem
      path = with pkgs; [
        btrfs-progs
        coreutils
        util-linux
      ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        set -euo pipefail

        mkdir -p /btrfs_tmp
        mount /dev/disk/by-partlabel/disk-main-root /btrfs_tmp
        mkdir -p /btrfs_tmp/root-backup

        # Back up the old root
        if [[ -e /btrfs_tmp/root ]]; then
            timestamp=$(date "+%Y-%m-%d_%H-%M-%S")
            mv /btrfs_tmp/root "/btrfs_tmp/root-backup/root-$timestamp"
        fi

        if [[ -e /btrfs_tmp/root-new ]]; then
            # Restore a root if it was placed in root-new
            mv /btrfs_tmp/root-new /btrfs_tmp/root
        else
            # Create a new empty root
            btrfs subvolume create /btrfs_tmp/root
        fi

        # Prune old backups over limit
        ls -1 /btrfs_tmp/root-backup | sort -r | tail -n +${toString (rootBackupLimit + 1)} | while read -r old; do
            btrfs subvolume delete -R "/btrfs_tmp/root-backup/$old"
        done

        umount /btrfs_tmp
      '';
    };

    boot.initrd.systemd.services.restore-persistent = {
      description = "Restore persistent subvolume from /persistent-new";
      wantedBy = ["initrd.target"];
      after = [
        "local-fs-pre.target"
        "initrd-root-device.target"
        "reset-root.service" # avoid mounting /btrfs_tmp at the same time
      ];
      before = [
        "sysroot.mount"
        "initrd-preservation.target" # ensure /persistent is restored before preservation bind mounts
      ];
      path = with pkgs; [
        coreutils
        util-linux
      ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        set -euo pipefail

        mkdir -p /btrfs_tmp
        mount /dev/disk/by-partlabel/disk-main-root /btrfs_tmp
        mkdir -p /btrfs_tmp/persistent-backup

        # Restore a persistent subvolume if it was placed in persistent-new
        if [[ -e /btrfs_tmp/persistent-new ]]; then
            timestamp=$(date "+%Y-%m-%d_%H-%M-%S")
            mv /btrfs_tmp/persistent "/btrfs_tmp/persistent-backup/persistent-$timestamp"
            mv /btrfs_tmp/persistent-new /btrfs_tmp/persistent
        fi

        umount /btrfs_tmp
      '';
    };

    # Shell aliases to mount/unmount the root partition
    environment.shellAliases = {
      mount-backup = "sudo mkdir -p /mnt/backup && sudo mount -o ro /dev/disk/by-partlabel/disk-main-root /mnt/backup";
      umount-backup = "sudo umount /mnt/backup";
    };

    disko.devices.disk.main = {
      device = device;
      type = "disk";
      content.type = "gpt";

      content.partitions.boot = {
        name = "boot";
        size = "1M";
        type = "EF02";
      };

      content.partitions.esp = {
        name = "ESP";
        size = "1G";
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
        };
      };

      content.partitions.root = {
        name = "root";
        size = "100%";
        content = {
          type = "btrfs";
          extraArgs = [
            "-f"
            "-L"
            "nixos"
          ];
          subvolumes = {
            "/root" = {
              mountOptions = [
                "subvol=root"
                "noatime"
              ];
              mountpoint = "/";
            };
            "/persistent" = {
              mountOptions = [
                "subvol=persistent"
                "noatime"
              ];
              mountpoint = "/persistent";
            };
            "/nix" = {
              mountOptions = [
                "subvol=nix"
                "noatime"
              ];
              mountpoint = "/nix";
            };
          };
        };
      };
    };
  };
}
