{ self, ... }:
{
  flake.nixosModules.ableArcherConfiguration =
    { ... }:
    {
      imports = [
        self.nixosModules.queze
        self.nixosModules.agenix
        self.nixosModules.openssh
      ];

      networking.hostName = "able-archer";
      system.stateVersion = "25.11";
    };
}
