{ self, ... }:
{
  flake.nixosModules.ableArcherConfiguration = {
    imports = [
      self.nixosModules.standardSystem
      self.nixosModules.quezeUser
    ];
    host.hypervisor.type = "utm";

    networking.hostName = "able-archer";
    system.stateVersion = "25.11";
  };
}
