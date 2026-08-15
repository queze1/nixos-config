{
  self,
  inputs,
  ...
}: {
  flake.colmenaHive = inputs.colmena.lib.makeHive {
    meta = {
      nixpkgs = import inputs.nixpkgs-stable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    };

    defaults = {config, ...}: {
      deployment = {
        targetHost = config.networking.hostName;
        targetPort = 22;
        targetUser = "root";
        buildOnTarget = true;
      };
    };

    steadfast-dart = {
      imports = [self.nixosModules.steadfastDartConfiguration];
    };

    steadfast-defender = {
      imports = [self.nixosModules.steadfastDefenderConfiguration];
    };

    # steadfast-noon = {
    #   imports = [self.nixosModules.steadfastNoonConfiguration];
    # };
  };
}
