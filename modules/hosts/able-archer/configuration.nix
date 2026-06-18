{self, ...}: {
  flake.nixosModules.ableArcherConfiguration = {
    imports = [
      self.nixosModules.coreFeatures
      self.nixosModules.optionalFeatures

      self.nixosModules.allPrograms
      self.nixosModules.niriNoctalia

      self.nixosModules.queze
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
