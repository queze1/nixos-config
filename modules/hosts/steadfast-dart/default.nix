{
  inputs,
  self,
  ...
}: let
  hostname = "steadfast-dart";
in {
  # Fastest home server
  flake.nixosModules.steadfastDartConfiguration = {
    imports = [
      self.nixosModules.steadfastBase

      self.nixosModules.podmanContainers

      # Ingress & routing
      self.nixosModules.caddy
      self.nixosModules.cloudflared
      self.nixosModules.ddns
      self.nixosModules.tailscaleAuth

      # Self-hosted apps
      self.nixosModules.actual
      self.nixosModules.arkRpVisualisation
      self.nixosModules.beszel
      self.nixosModules.beszelClient
      self.nixosModules.musicStack
      self.nixosModules.nextcloud
      self.nixosModules.pihole
      self.nixosModules.sillytavern
      self.nixosModules.vaultwarden
    ];

    # Set incrementing port numbers
    my.apps.actual.port = 8000;
    my.apps.ark-rp-viz.port = 8001;
    my.apps.metube.port = 8002;
    my.apps.nextcloud.port = 8003;
    my.apps.picard.port = 8004;
    my.apps.pihole.ports = ["8005"];
    my.apps.sillytavern.port = 8006;
    my.apps.vaultwarden.port = 8007;
    my.apps.yubal.port = 8008;

    my.restic = {
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

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = [self.nixosModules.steadfastDartConfiguration];
  };
}
