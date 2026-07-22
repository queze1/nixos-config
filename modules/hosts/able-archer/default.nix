{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.able-archer = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.ableArcherConfiguration
      self.nixosModules.ableArcherHardware
    ];
  };
}
