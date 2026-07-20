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

  flake.factory.diskoBrtfs = {device}: {pkgs, ...}: {
    imports = [inputs.disko.nixosModules.default];

    fileSystems."/nix".neededForBoot = true;
    fileSystems."/persistent".neededForBoot = true;

    boot.initrd.systemd.services.reset-root = {
      description = "Backup root subvolume and create a empty root";
      wantedBy = ["initrd.target"];
      after = [
        "local-fs-pre.target" # when filesystems are ready for mounting
        "initrd-root-device.target" # when the root filesystem device is avaliable but before it's mounted
      ];
      before = ["sysroot.mount"]; # mounts the root system
      path = with pkgs; [
        btrfs-progs
        coreutils
        util-linux
      ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /btrfs_tmp
        mount /dev/disk/by-partlabel/disk-main-root /btrfs_tmp

        # Delete the backup if it exists
        if [[ -e /btrfs_tmp/root-backup ]]; then
            btrfs subvolume delete --recursive /btrfs_tmp/root-backup
        fi

        # Back up the old root
        if [[ -e /btrfs_tmp/root ]]; then
            mv /btrfs_tmp/root /btrfs_tmp/root-backup
        fi

        # Create a new empty root
        btrfs subvolume create /btrfs_tmp/root

        umount /btrfs_tmp
      '';
    };

    environment.shellAliases = {
      mount-backup = "sudo mkdir -p /mnt/backup && sudo mount -o subvol=root-backup,ro /dev/disk/by-partlabel/disk-main-root /mnt/backup";
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
