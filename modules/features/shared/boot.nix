{
  flake.nixosModules.sharedModules = {
    pkgs,
    lib,
    ...
  }: {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.configurationLimit = lib.mkDefault 10;

    # Use latest LTS kernel
    boot.kernelPackages = pkgs.linuxPackages;
  };
}
