{
  inputs,
  self,
  ...
}: let
  hostname = "trident-lance";
  sshKeys = import "${self}/ssh-keys.nix";
in {
  flake.nixosModules.tridentLanceConfiguration = {
    imports = [
      self.nixosModules.openssh
    ];

    boot = {
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = false;
      initrd.availableKernelModules = [
        "virtio_pci"
        "virtio_scsi"
        "usbhid"
        "nvme"
      ];
    };

    users.users.nixos = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];
    };

    # Allow SSH into root
    users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];

    systemd.network.enable = false;
    networking = {
      useDHCP = true;
      dhcpcd.enable = true;
      useNetworkd = false;
    };
    security.sudo.wheelNeedsPassword = false;
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 150; # 1GB RAM -> 1.5GB zram
      priority = 10;
    };

    networking.hostName = hostname;
    system.stateVersion = "25.11";
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [self.nixosModules.tridentLanceConfiguration];
  };
}
