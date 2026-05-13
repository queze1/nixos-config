{ self, ... }:
{
  flake.nixosModules.ableArcherConfiguration =
    { ... }:
    {
      imports = [
        self.nixosModules.ableArcherHardware
      ];

      networking.hostName = "able-archer";
      system.stateVersion = "25.11";
    };
}
