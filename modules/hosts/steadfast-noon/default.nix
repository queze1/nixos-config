{ self, inputs, ... }:
{
  flake.nixosConfigurations.steadfast-noon = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.steadfastNoonConfiguration
      self.nixosModules.steadfastNoonHardware
    ];

    specialArgs = {
      profile = "home-server";
    };
  };
}
