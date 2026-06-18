{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.steadfast-defender = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.steadfastDefenderConfiguration
    ];
  };
}
