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

      # Ingress & routing
      self.nixosModules.caddy
      self.nixosModules.caddyCloudflareDNS
      self.nixosModules.cloudflared
      self.nixosModules.ddns

      # Hosted services
      self.nixosModules.attic
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
