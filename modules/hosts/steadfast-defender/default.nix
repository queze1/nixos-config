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
      (self.factory.diskoBrtfs
        {device = "/dev/nvme0n1";})

      # Ingress & routing
      self.nixosModules.caddy
      self.nixosModules.ddns
      self.nixosModules.tailscaleAuth

      # Hosted services
      self.nixosModules.resticServer
    ];

    my.restic = {
      extraPaths = [
        "/persistent/etc/ssh"
        "/persistent/var/lib/nixos"
        "/persistent/var/lib/tailscale"
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
