{
  self,
  inputs,
  ...
}: {
  # TODO: Use nix-factor for home servers
  flake.nixosConfigurations.steadfast-defender = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.steadfastDefenderConfiguration
      self.nixosModules.steadfastDefenderHardware
    ];
  };
}
