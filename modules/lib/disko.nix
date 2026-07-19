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

  flake.factory.diskoBrtfs = {device}: {
    imports = [inputs.disko.nixosModules.default];

    fileSystems."/nix".neededForBoot = true;
    fileSystems."/persistent".neededForBoot = true;

    # TODO: Clear root on reboot

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
          ];
          subvolumes = {
            "/root" = {
              mountpoint = "/";
            };
            "/persistent" = {
              mountOptions = [
                "noatime"
              ];
              mountpoint = "/persistent";
            };
            "/nix" = {
              mountOptions = [
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
