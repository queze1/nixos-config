{
  inputs,
  self,
  ...
}: let
  hostname = "steadfast-dart";
  system = "x86_64-linux";
in {
  # Fastest home server
  flake.nixosModules.steadfastDartConfiguration = {
    imports = [
      self.nixosModules.steadfastBase
      (self.factory.diskoTmpfsOnRoot
        {device = "/dev/nvme0n1";})
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
    services.metube.port = 8002;
    services.yubal.port = 8003;
    services.picard.port = 8005;
    services.pihole-web.ports = [8006];

    my.restic.backups = {
      backblaze-b2 = {
        paths = [
          "/srv/music"
        ];
      };
    };

    hardware.facter.reportPath = ./facter.json;
    networking.hostName = hostname;
  };

  flake.nixosConfigurations.${hostname} =
    inputs.nixpkgs-stable.lib.nixosSystem {
      modules = [self.nixosModules.steadfastDartConfiguration];
    }
    // {_system = system;};
}
