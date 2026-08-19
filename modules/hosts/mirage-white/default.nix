{
  inputs,
  self,
  ...
}: let
  hostname = "mirage-white";
in {
  # DigitalOcean droplet
  flake.nixosModules.mirageWhiteConfiguration = {
    imports = [
      self.nixosModules.mirageBase
      self.nixosModules.resticDefaults

      # Ingress & routing
      self.nixosModules.cloudflared

      # Hosted services
      self.nixosModules.gatus
    ];

    # Prevent port overlap
    my.apps.gatus.port = 8000;

    my.restic = {
      backups.backblaze-b2 = {
        timerConfig = {
          OnCalendar = "daily";
          RandomizedDelaySec = "4h";
          Persistent = true;
        };
      };
    };

    networking.hostName = hostname;
  };

  flake.nixosConfigurations.${hostname} = self.factory.mkNixosSystem {
    nixpkgs = inputs.nixpkgs-stable;
    system = "x86_64-linux";
    modules = [
      self.nixosModules.mirageWhiteConfiguration
      self.nixosModules.mirageWhiteHardware
    ];
  };
}
