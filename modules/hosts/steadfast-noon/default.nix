{
  self,
  inputs,
  ...
}: let
  hostname = "steadfast-noon";
in {
  # Other home server
  flake.nixosModules.steadfastNoonConfiguration = {
    imports = [self.nixosModules.steadfastBase];
    hardware.facter.reportPath = ./facter.json;
    networking.hostName = "${hostname}";
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.steadfastNoonConfiguration];
  };
}
