{
  inputs,
  self,
  ...
}: let
  hostname = "steadfast-dart";
in {
  # Fastest home server
  flake.nixosModules.steadfastDartConfiguration = {config, ...}: {
    imports = [
      self.nixosModules.steadfastBase
      self.nixosModules.podmanContainers

      # Ingress & routing
      self.nixosModules.caddy
      self.nixosModules.cloudflared
      self.nixosModules.ddns
      self.nixosModules.tailscaleAuth

      # Self-hosted apps
      self.nixosModules.arkRpVisualisation
      self.nixosModules.musicStack
      self.nixosModules.pihole
      self.nixosModules.sillytavern
    ];

    # Set incrementing port numbers
    services.ark-rp-viz.port = 8000;
    services.navidrome.settings.Port = 8001;
    services.metube.port = 8002;
    services.yubal.port = 8003;
    services.picard.port = 8005;
    services.pihole-web.ports = [8006];

    sops.secrets.restic-backblaze-b2-repo.sopsFile = "${inputs.secrets}/secrets/server.yaml";
    sops.secrets.restic-backblaze-b2-env.sopsFile = "${inputs.secrets}/secrets/server.yaml";
    sops.secrets.restic-backblaze-b2-pass.sopsFile = "${inputs.secrets}/secrets/server.yaml";

    services.restic.backups = {
      backblaze-b2 = {
        repositoryFile = config.sops.secrets.restic-backblaze-b2-repo.path;
        environmentFile = config.sops.secrets.restic-backblaze-b2-env.path;
        passwordFile = config.sops.secrets.restic-backblaze-b2-pass.path;
        initialize = true;

        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };

        paths = [
          "/srv/music"
        ];
      };
    };

    hardware.facter.reportPath = ./facter.json;
    networking.hostName = "${hostname}";
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = [self.nixosModules.steadfastDartConfiguration];
  };
}
