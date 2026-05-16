{ self, ... }:
{
  flake.nixosModules.ableArcherConfiguration = {
    imports = [
      self.nixosModules.allPrograms
      self.nixosModules.desktop
      self.nixosModules.queze
      self.nixosModules.standardSystem
    ];
    host.hypervisor.type = "utm";

    networking.hostName = "able-archer";
    system.stateVersion = "25.11";
  };
}
