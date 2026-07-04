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
      modules = [self.nixosModules.steadfastDartConfiguration];
    };

    steadfast-defender = {
      modules = [self.nixosModules.steadfastDefenderConfiguration];

      deployment = {
        targetHost = "steadfast-defender";
        targetPort = 22;
        targetUser = "commander";
      };
    };

    steadfast-noon = {
      modules = [self.nixosModules.steadfastNoonConfiguration];
    };
  };
}
