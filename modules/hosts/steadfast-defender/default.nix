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

      self.nixosModules.btrbk
      (self.factory.diskoBrtfsEphemeralRoot
        {device = "/dev/nvme0n1";})
      self.nixosModules.laptopServer

      # Ingress & routing
      self.nixosModules.caddy
      self.nixosModules.ddns
      self.nixosModules.tailscaleAuth

      # Hosted services
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
    };

    hardware.facter.reportPath = ./facter.json;
    networking.hostName = hostname;
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = [self.nixosModules.steadfastDefenderConfiguration];
  };
}
