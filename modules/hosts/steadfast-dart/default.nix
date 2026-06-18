{
  self,
  inputs,
  ...
}: let
  hostname = "steadfast-dart";
in {
  # Fastest home server
  flake.nixosModules.steadfastDartConfiguration = {
    imports = [self.nixosModules.steadfastBase];
    hardware.facter.reportPath = ./facter.json;
    networking.hostName = "${hostname}";
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.steadfastDartConfiguration];
  };
}
