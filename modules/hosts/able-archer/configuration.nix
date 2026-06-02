{ self, ... }:
{
  flake.nixosModules.ableArcherConfiguration = {
    imports = [
      self.nixosModules.allPrograms
      self.nixosModules.queze
      self.nixosModules.standardSystem
      self.nixosModules.niriNoctalia
    ];

    host = {
      hypervisor.type = "utm";
      disko.profile = "hybrid-tmpfs-on-root";
      preservation.enable = true;
    };

    networking.hostName = "able-archer";
    system.stateVersion = "25.11";

  };
}
