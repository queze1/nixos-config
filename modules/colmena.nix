{
  self,
  inputs,
  ...
}: {
  flake.colmenaHive = inputs.colmena.lib.makeHive {
    meta = {
      nixpkgs = import inputs.nixpkgs-stable {
        system = "x86_64-linux";
      };
    };

    steadfast-dart = {
      imports = [self.nixosModules.steadfastDartConfiguration];
    };

    steadfast-defender = {
      imports = [self.nixosModules.steadfastDefenderConfiguration];

      deployment = {
        targetHost = "steadfast-defender";
        targetPort = 22;
        targetUser = "root";
        buildOnTarget = true;
      };
    };

    steadfast-noon = {
      imports = [self.nixosModules.steadfastNoonConfiguration];
    };
  };
}
