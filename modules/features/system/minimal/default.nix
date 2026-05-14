{ self, ... }:
{
  flake.nixosModules.minimalSystem =
    { inputs, ... }:
    {
      imports = [
        #  inputs.home-manager.flakeModules.home-manager
        self.nixosModules.agenix
        self.nixosModules.disko
      ];
    };
}
