{ inputs, ... }:
{
  flake.nixosModules.disko =
    { config, lib, ... }:
    let
      cfg = config.host.disko;
    in
    {
      imports = [ inputs.disko.nixosModules.default ];

      options.host.disko = {
        profile = lib.mkOption {
          type = lib.types.enum [
            "simple-efi"
            "hybrid-tmpfs-on-root"
          ];
          default = "simple-efi";
          description = "Select disk config";
        };
        device = lib.mkOption {
          type = lib.types.str;
          default =
            if config.host.hypervisor.type == "utm" then
              "/dev/vda"
            else if config.host.hypervisor.type == "vmware" then
              "/dev/sda"
            else
              "/dev/nvme0n1";
        };
      };

      config = lib.mkMerge [
        # Simple filesystem, no swap
        (lib.mkIf (cfg.profile == "simple-efi") {
          disko.devices.disk.main = {
            device = cfg.device;
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                # 500M boot
                ESP = {
                  type = "EF00";
                  size = "500M";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                  };
                };
                root = {
                  size = "100%";
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                  };
                };
              };
            };
          };
        })

        # Mostly copied from https://www.vimjoyer.com/vid89-impermanent/disko
        (lib.mkIf (cfg.profile == "hybrid-tmpfs-on-root") {
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
            device = cfg.device;
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
                resumeDevice = true;
              };
            };

            content.partitions.root = {
              name = "root";
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
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
        })
      ];
    };
}
