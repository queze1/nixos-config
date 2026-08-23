{
  inputs,
  self,
  ...
}: let
  hostname = "mirage-blue";
in {
  # 512mb Oracle Cloud instance
  flake.nixosModules.mirageBlueConfiguration = {...}: {
    imports = [
      self.nixosModules.mirageBase
    ];

    my.caddy = {
      enable = true;
      cloudflareDns.enable = true;
    };
    my.ddns.enable = true;
    my.tailscaleAuth.enable = true;

    # Hosted services
    my.apps.beszel-hub.enable = true;

    networking.hostName = hostname;
  };

  flake.nixosConfigurations.${hostname} = self.factory.mkNixosSystem {
    nixpkgs = inputs.nixpkgs-stable;
    system = "x86_64-linux";
    modules = [
      self.nixosModules.mirageBlueConfiguration
      self.nixosModules.mirageBlueHardware
    ];
  };
}
