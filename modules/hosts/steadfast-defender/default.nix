{
  self,
  inputs,
  ...
}: let
  hostname = "steadfast-defender";
in {
  # ThinkPad home server
  flake.nixosModules.steadfastDefenderConfiguration = {
    imports = [
      self.nixosModules.steadfastBase
      (self.factory.diskoBrtfs
        {device = "/dev/nvme0n1";})

      # Hosting
      self.nixosModules.caddy
      self.nixosModules.cloudflared
      self.nixosModules.garage
    ];

    hardware.facter.reportPath = ./facter.json;
    networking.hostName = hostname;
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = [self.nixosModules.steadfastDefenderConfiguration];
  };
}
