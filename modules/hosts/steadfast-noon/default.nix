{
  self,
  inputs,
  ...
}: let
  hostname = "steadfast-noon";
in {
  # Other home server
  flake.nixosModules.steadfastNoonConfiguration = {
    imports = [
      self.nixosModules.steadfastBase
      (self.factory.diskoBrtfs
        {device = "/dev/nvme0n1";})
    ];
    hardware.facter.reportPath = ./facter.json;
    networking.hostName = "${hostname}";
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = [self.nixosModules.steadfastNoonConfiguration];
  };
}
