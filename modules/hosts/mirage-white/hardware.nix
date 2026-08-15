{
  flake.nixosModules.mirageWhiteHardware = {
    lib,
    modulesPath,
    ...
  }: {
    imports = ["${modulesPath}/virtualisation/amazon-image.nix"];
    ec2.efi = true;

    boot.initrd.availableKernelModules = ["nvme"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = [];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/f222513b-ded1-49fa-b591-20ce86a2fe7f";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/12CE-A600";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };

    swapDevices = [];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}
