{
  inputs,
  self,
  ...
}: let
  hostname = "steadfast-dart";
  system = "x86_64-linux";
in {
  # Fastest home server
  flake.nixosModules.steadfastDartConfiguration = {config, ...}: {
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

    # Allow only Caddy to access services
    networking.nftables.tables."caddy-firewall" = {
      family = "inet";
      content = ''
        chain output {
          type filter hook output priority filter; policy accept;

          oif "lo" tcp dport { 8000 8002 8003 8005 8006 } meta skuid ${toString config.users.users.${config.services.caddy.user}.uid} accept
          oif "lo" tcp dport { 8000 8002 8003 8005 8006 } drop
        }
      '';
    };

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
