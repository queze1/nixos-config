{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.boot;
in {
  options.my.boot = {
    systemdBoot.enable = lib.mkEnableOption "systemd-boot with EFI variables";
    useLatestLtsKernel = lib.mkEnableOption "the latest LTS kernel";
    configurationLimit = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.systemdBoot.enable {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
    })
    (lib.mkIf cfg.useLatestLtsKernel {
      boot.kernelPackages = pkgs.linuxPackages;
    })
    (lib.mkIf (cfg.configurationLimit != null) {
      boot.loader.grub.configurationLimit = cfg.configurationLimit;
      boot.loader.systemd-boot.configurationLimit = cfg.configurationLimit;
    })
  ];
}
