{
  inputs,
  self,
  ...
}: let
  sshKeys = import "${self}/ssh-keys.nix";
  hostname = "mirage-red";
in {
  # 512mb Oracle Cloud instance
  flake.nixosModules.mirageRedConfiguration = {pkgs, ...}: {
    imports = [
      self.nixosModules.myOptions

      # System config
      self.nixosModules.openssh
    ];

    # Helper programs
    environment.systemPackages = with pkgs; [
      htop
      ncdu
      ssh-to-age
    ];

    # Allow SSH into root
    users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];

    zramSwap = {
      enable = true;
      memoryPercent = 100;
    };

    # Minimise Nix store size
    boot.loader.grub.configurationLimit = 3;
    nix.gc = {
      automatic = true;
      options = "--delete-old";
    };
    nix.settings.auto-optimise-store = true;

    # Disable documentation
    documentation.enable = false;

    nix.settings.experimental-features = ["nix-command" "flakes"];

    networking.hostName = hostname;
    system.stateVersion = "26.05";
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    pkgs = import inputs.nixpkgs-stable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };

    modules = [
      self.nixosModules.mirageRedConfiguration
      self.nixosModules.mirageRedHardware
    ];
  };
}
