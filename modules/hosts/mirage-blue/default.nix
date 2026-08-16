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

    networking.hostName = hostname;
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    pkgs = import inputs.nixpkgs-stable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };

    modules = [
      self.nixosModules.mirageBlueConfiguration
      self.nixosModules.mirageBlueHardware
    ];
  };
}
