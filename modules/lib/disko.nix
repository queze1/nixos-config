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

    boot.initrd.systemd.services.setup-subvolumes = {
      description = "Set up /root and /persistent";
      wantedBy = ["initrd.target"];
      after = [
        "local-fs-pre.target" # when filesystems are ready for mounting
        "initrd-root-device.target" # when the root filesystem device is avaliable but before it's mounted
        "dev-disk-by\x2dpartlabel-disk\x2dmain\x2droot.device"
      ];
      requires = [
        "dev-disk-by\\x2dpartlabel-disk\\x2dmain\\x2droot.device"
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
        mkdir -p /btrfs_tmp/persistent-backup

        # Back up the old root
        if [[ -e /btrfs_tmp/root ]]; then
            timestamp=$(date "+%Y-%m-%d_%H-%M-%S")
            mv /btrfs_tmp/root "/btrfs_tmp/root-backup/root-$timestamp"
        fi

        if [[ -e /btrfs_tmp/root-restore ]]; then
            # Restore a root if it was placed in root-restore
            mv /btrfs_tmp/root-restore /btrfs_tmp/root
        else
            # Create a new empty root
            btrfs subvolume create /btrfs_tmp/root
        fi

        # Prune old backups over limit
        ls -1 /btrfs_tmp/root-backup | sort -r | tail -n +${toString (rootBackupLimit + 1)} | while read -r old; do
            btrfs subvolume delete -R "/btrfs_tmp/root-backup/$old"
        done

        # Restore a persistent subvolume if it was placed in persistent-restore
        if [[ -e /btrfs_tmp/persistent-restore ]]; then
            timestamp=$(date "+%Y-%m-%d_%H-%M-%S")
            mv /btrfs_tmp/persistent "/btrfs_tmp/persistent-backup/persistent-$timestamp"
            mv /btrfs_tmp/persistent-restore /btrfs_tmp/persistent
        fi

        umount /btrfs_tmp
      '';
    };

    # Shell aliases to mount/unmount the top-level subpartition
    environment.shellAliases = {
      mount-top-level = "sudo mkdir -p /mnt/top-level && sudo mount -o subvolid=5 /dev/disk/by-partlabel/disk-main-root /mnt/top-level";
      umount-top-level = "sudo umount /mnt/top-level";
    };

    specialisation.root-preview.configuration = {lib, ...}: {
      disko.devices.disk.main.content.partitions.root.content.subvolumes = {
        "/root" = {
          mountpoint = lib.mkForce "/root-original";
        };
        "/root-preview" = {
          mountOptions = ["noatime"];
          mountpoint = "/root";
        };
      };
    };

    specialisation.persistent-preview.configuration = {lib, ...}: {
      disko.devices.disk.main.content.partitions.root.content.subvolumes = {
        "/persistent" = {
          mountpoint = lib.mkForce "/persistent-original";
        };
        "/persistent-preview" = {
          mountOptions = ["noatime"];
          mountpoint = "/persistent";
        };
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
              mountOptions = ["noatime"];
              mountpoint = "/";
            };
            "/persistent" = {
              mountOptions = ["noatime"];
              mountpoint = "/persistent";
            };
            "/nix" = {
              mountOptions = ["noatime"];
              mountpoint = "/nix";
            };
          };
        };
      };
    };
  };
}
