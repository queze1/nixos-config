{
  inputs,
  self,
  ...
}: let
  hostname = "mirage-white";
in {
  # DigitalOcean droplet (UNUSED)
  flake.nixosModules.mirageWhiteConfiguration = {
    imports = [
      self.nixosModules.mirageBase
    ];

    my.cloudflared.enable = true;
    my.apps.gatus.enable = true;

    # Prevent port overlap
    my.apps.gatus.port = 8000;

    # Backups
    my.restic = {
      enable = true;
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
