{ self, inputs, ... }:
{
  # For fastest home server
  # TODO: Use nix-factor for home servers
  flake.nixosConfigurations.steadfast-dart = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.steadfastDartConfiguration
      self.nixosModules.steadfastDartHardware
    ];
  };
}
