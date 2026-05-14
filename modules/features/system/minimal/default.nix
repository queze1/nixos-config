{ self, inputs, ... }:
{
  flake.nixosModules.minimalSystem = {
    imports = [
      # Allow use of home-manager inside NixOS modules
      # E.g. home-manager.sharedModules
      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.agenix
      self.nixosModules.disko

      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
      }
    ];
  };
}
