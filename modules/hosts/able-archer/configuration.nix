{ self, ... }:
{
  flake.nixosModules.ableArcherConfiguration =
    { ... }:
    {
      imports = [
        self.nixosModules.queze
        self.nixosModules.allFeatures
      ];

      networking.hostName = "able-archer";
      system.stateVersion = "25.11";
    };
}
