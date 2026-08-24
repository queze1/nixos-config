{
  self,
  inputs,
  ...
}: let
  hostname = "steadfast-defender";
in {
  # ThinkPad home server
  flake.nixosModules.steadfastDefenderConfiguration = {
    my.profiles.home-server.enable = true;

    # Ingress & routing
    my.ddns.enable = true;
    my.caddy = {
      enable = true;
      cloudflareDns.enable = true;
    };

    # Hosted services
    my.apps = {
      autoAssignPorts = true;
      attic.enable = true;
      immich.enable = true;
      restic-server.enable = true;
    };

    # Backups
    my.restic = {
      enable = true;
      snapshotsDir = "/persistent/snapshots";
      extraPaths = [
        "/etc/ssh"
        "/var/lib/nixos"
        "/var/lib/tailscale"
      ];
      backups.backblaze-b2 = {
        timerConfig = {
          OnCalendar = "daily";
          RandomizedDelaySec = "4h";
          Persistent = true;
        };
      };
      backups.local-server = {
        timerConfig = {
          OnCalendar = "hourly";
          RandomizedDelaySec = "15m";
          Persistent = true;
        };
      };
    };

    hardware.facter.reportPath = ./facter.json;
    networking.hostName = hostname;
  };

  flake.nixosConfigurations.${hostname} = self.factory.mkNixosSystem {
    nixpkgs = inputs.nixpkgs-stable;
    system = "x86_64-linux";
    modules = [self.nixosModules.steadfastDefenderConfiguration];
  };
}
