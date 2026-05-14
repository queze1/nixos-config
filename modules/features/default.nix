{ self, ... }:
{
  flake.nixosModules.allFeatures =
    {
      ...
    }:
    {
      imports = [
        self.nixosModules.agenix
        self.nixosModules.openssh
      ];
    };
}
