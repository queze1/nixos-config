{ self, inputs, ... }:
{
  # For fastest home server
  flake.nixosConfigurations.steadfast-dart = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.steadfastDartConfiguration
      self.nixosModules.steadfastDartHardware
    ];

    specialArgs = {
      profile = "home-server";
    };
  };
}
