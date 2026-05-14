{ self, inputs, ... }:
{
  flake.nixosConfigurations.steadfast-defender = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.steadfastDefenderConfiguration
      self.nixosModules.steadfastDefenderHardware
    ];

    specialArgs = {
      profile = "home-server";
    };
  };
}
