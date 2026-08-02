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

      self.nixosModules.btrbk
      (self.factory.diskoTmpfsOnRoot
        {device = "/dev/nvme0n1";})
      self.nixosModules.podmanContainers

      # Ingress & routing
      self.nixosModules.caddy
      self.nixosModules.cloudflared
      self.nixosModules.ddns
      self.nixosModules.tailscaleAuth

      # Self-hosted apps
      self.nixosModules.actual
      self.nixosModules.arkRpVisualisation
      self.nixosModules.musicStack
      self.nixosModules.pihole
      self.nixosModules.sillytavern
    ];

    # Set incrementing port numbers
    services.actual.settings.port = 8000;
    services.ark-rp-viz.port = 8001;
    services.metube.port = 8002;
    services.picard.port = 8003;
    services.pihole-web.ports = ["8004"];
    services.sillytavern.port = 8005;
    services.yubal.port = 8006;

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
