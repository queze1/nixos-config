{
  inputs,
  self,
  ...
}: let
  hostname = "steadfast-dart";
in {
  # Newer home server
  flake.nixosModules.steadfastDartConfiguration = {
    imports = [
      self.nixosModules.steadfastBase
    ];

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

    # Set incrementing port numbers
    my.apps.actual.port = 8000;
    my.apps.ark-rp-viz.port = 8001;
    my.apps.metube.port = 8002;
    my.apps.picard.port = 8003;
    my.apps.pihole.port = 8004;
    my.apps.sillytavern.port = 8005;
    my.apps.vaultwarden.port = 8006;
    my.apps.yubal.port = 8007;
    # my.apps.filebrowser-quantum.port = 8008;

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
