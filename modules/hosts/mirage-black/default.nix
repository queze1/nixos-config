{
  inputs,
  self,
  ...
}: let
  sshKeys = import "${self}/ssh-keys.nix";
  hostname = "mirage-black";
in {
  # DigitalOcean droplet
  flake.nixosModules.mirageBlackConfiguration = {pkgs, ...}: {
    imports = [
      self.nixosModules.myOptions

      self.nixosModules.openssh
    ];

    # Helper programs
    environment.systemPackages = with pkgs; [
      htop
      ncdu
      nix-du
      ssh-to-age
    ];

    zramSwap.enable = true;

    # Allow SSH into root
    users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];

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
      self.nixosModules.mirageBlackConfiguration
      self.nixosModules.mirageBlackHardware
    ];
  };
}
