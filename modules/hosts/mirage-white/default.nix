{
  inputs,
  self,
  ...
}: let
  hostname = "mirage-white";
in {
  # DigitalOcean droplet
  flake.nixosModules.mirageWhiteConfiguration = {...}: {
    imports = [
      self.nixosModules.mirageBase

      # Hosted services
      self.nixosModules.cloudflared
      self.nixosModules.gatus
    ];

    networking.hostName = hostname;
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    pkgs = import inputs.nixpkgs-stable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };

    modules = [
      self.nixosModules.mirageWhiteConfiguration
      self.nixosModules.mirageWhiteHardware
    ];
  };
}
