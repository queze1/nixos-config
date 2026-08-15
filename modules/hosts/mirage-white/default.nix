{
  inputs,
  self,
  ...
}: let
  hostname = "mirage-white";
in {
  # Tiny EC2 instance
  flake.nixosModules.mirageWhiteConfiguration = {
    zramSwap = {
      enable = true;
      memoryPercent = 100;
    };

    nix.settings.experimental-features = ["nix-command" "flakes"];

    networking.hostName = hostname;
    system.stateVersion = "26.05";
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    pkgs = import inputs.nixpkgs-stable {
      system = "aarch64-linux";
      config.allowUnfree = true;
    };

    modules = [
      self.nixosModules.mirageWhiteConfiguration
      self.nixosModules.mirageWhiteHardware
    ];
  };
}
