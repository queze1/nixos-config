{ self, ... }:
{
  flake.nixosModules.ableArcherConfiguration = {
    imports = [
      self.nixosModules.allFeatures
      self.nixosModules.queze
    ];
    host.profile = "personal-computer";
    host.hypervisor.type = "utm";

    networking.hostName = "able-archer";
    system.stateVersion = "25.11";
  };
}
