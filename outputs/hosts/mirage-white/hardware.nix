{
  flake.nixosModules.mirageWhiteHardware = {
    modulesPath,
    lib,
    ...
  }: {
    imports = [(modulesPath + "/profiles/qemu-guest.nix")];

    boot.loader.grub.device = "/dev/vda";
    boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi"];
    boot.initrd.kernelModules = ["nvme"];
    fileSystems."/" = {
      device = "/dev/vda1";
      fsType = "ext4";
    };

    networking = {
      nameservers = [
        "8.8.8.8"
      ];
      defaultGateway = "170.64.128.1";
      dhcpcd.enable = false;
      usePredictableInterfaceNames = lib.mkForce false;
      interfaces = {
        eth0 = {
          ipv4.addresses = [
            {
              address = "170.64.131.90";
              prefixLength = 19;
            }
            {
              address = "10.49.0.5";
              prefixLength = 16;
            }
          ];
          ipv6.addresses = [
            {
              address = "fe80::709a:a3ff:feaf:30c1";
              prefixLength = 64;
            }
          ];
          ipv4.routes = [
            {
              address = "170.64.128.1";
              prefixLength = 32;
            }
          ];
        };
        eth1 = {
          ipv4.addresses = [
            {
              address = "10.126.0.3";
              prefixLength = 20;
            }
          ];
          ipv6.addresses = [
            {
              address = "fe80::f4c8:21ff:fec4:63b9";
              prefixLength = 64;
            }
          ];
        };
      };
    };
    services.udev.extraRules = ''
      ATTR{address}=="72:9a:a3:af:30:c1", NAME="eth0"
      ATTR{address}=="f6:c8:21:c4:63:b9", NAME="eth1"
    '';
  };
}
