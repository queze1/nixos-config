{
  self,
  inputs,
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
      self.nixosModules.arkRpVisualisation
      self.nixosModules.musicStack
      self.nixosModules.pihole
      self.nixosModules.sillytavern
    ];

    # Set incrementing port numbers
    services.ark-rp-viz.port = 8000;
    services.navidrome.settings.Port = 8001;
    services.pihole-web.ports = [8002];
    services.yubal.port = 8003;

    hardware.facter.reportPath = ./facter.json;
    networking.hostName = "${hostname}";
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = [self.nixosModules.steadfastDartConfiguration];
  };
}
