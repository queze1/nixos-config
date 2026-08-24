{
  inputs,
  self,
  ...
}: let
  hostname = "steadfast-dart";
in {
  # Newer home server
  flake.nixosModules.steadfastDartConfiguration = {
    my.profiles.home-server.enable = true;

    my.podmanContainers.enable = true;

    # Ingress & routing
    my.cloudflared.enable = true;
    my.ddns.enable = true;
    my.tailscaleAuth.enable = true;
    my.caddy = {
      enable = true;
      cloudflareDns.enable = true;
    };

    # Hosted services
    my.apps = {
      autoAssignPorts = true;
      actual.enable = true;
      ark-rp-viz.enable = true;
      forgejo.enable = true;
      github2forgejo.enable = true;
      music-stack.enable = true;
      pihole.enable = true;
      restic-server.enable = true;
      sillytavern.enable = true;
      vaultwarden.enable = true;
    };

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
    modules = [self.nixosModules.steadfastDartConfiguration];
  };
}
