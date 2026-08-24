{
  inputs,
  self,
  ...
}: let
  hostname = "mirage-red";
in {
  # 512mb Oracle Cloud instance
  flake.nixosModules.mirageRedConfiguration = {...}: {
    imports = [
      self.nixosModules.mirageBase
    ];

    my.cloudflared.enable = true;
    my.apps.gatus.enable = true;

    networking.hostName = hostname;
  };

  flake.nixosConfigurations.${hostname} = self.factory.mkNixosSystem {
    nixpkgs = inputs.nixpkgs-stable;
    system = "x86_64-linux";
    modules = [
      self.nixosModules.mirageRedConfiguration
      self.nixosModules.mirageRedHardware
    ];
  };
}
