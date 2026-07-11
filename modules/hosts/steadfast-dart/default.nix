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

      # Self-hosted apps
      self.nixosModules.arkRpVisualisation
      self.nixosModules.caddy
      self.nixosModules.musicStack
      self.nixosModules.sillytavern
    ];

    hardware.facter.reportPath = ./facter.json;
    networking.hostName = "${hostname}";
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = [self.nixosModules.steadfastDartConfiguration];
  };
}
