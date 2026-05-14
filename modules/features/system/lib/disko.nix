{ inputs, lib, ... }:
{
  flake.nixosModules.disko =
    { config, ... }:
    let
      cfg = config.disko;
    in
    {
      imports = [ inputs.disko.nixosModules.default ];

      options.disko = {
        profile = lib.mkOption {
          type = lib.types.enum [
            "simple-efi"
            # TODO: Create disko config for impermanence
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
        (lib.mkIf (cfg.profile == "simple-efi") {
          disko.devices.disk.main = {
            device = config.customOptions.disko.device;
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
      ];
    };
}
