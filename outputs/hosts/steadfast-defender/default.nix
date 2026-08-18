{
  self,
  inputs,
  ...
}: let
  hostname = "steadfast-defender";
in {
  # ThinkPad home server
  flake.nixosModules.steadfastDefenderConfiguration = {
    imports = [
      self.nixosModules.steadfastBase

      # Ingress & routing
      self.nixosModules.caddy
      self.nixosModules.caddyCloudflareDNS
      self.nixosModules.cloudflared
      self.nixosModules.ddns
      self.nixosModules.tailscaleAuth

      # Hosted services
      self.nixosModules.attic
      self.nixosModules.beszelHub
      self.nixosModules.immich
      self.nixosModules.resticServer
    ];

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

  flake.nixosConfigurations.${hostname} = self.factory.mkNixosSystem {
    nixpkgs = inputs.nixpkgs-stable;
    system = "x86_64-linux";
    modules = [self.nixosModules.steadfastDefenderConfiguration];
  };
}
