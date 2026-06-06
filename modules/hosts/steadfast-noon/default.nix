{
  self,
  inputs,
  ...
}: {
  # TODO: Use nix-factor for home servers
  flake.nixosConfigurations.steadfast-noon = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.steadfastNoonConfiguration
      self.nixosModules.steadfastNoonHardware
    ];
  };
}
