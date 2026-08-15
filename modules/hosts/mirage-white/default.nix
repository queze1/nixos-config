{
  inputs,
  self,
  ...
}: let
  hostname = "mirage-white";
in {
  # Tiny EC2 instance
  flake.nixosModules.mirageWhiteConfiguration = {
    networking.hostName = hostname;
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
