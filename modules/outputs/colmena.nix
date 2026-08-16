{
  self,
  inputs,
  ...
}: {
  flake.colmenaHive = let
    pkgs_x86 = import inputs.nixpkgs-stable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
  in
    inputs.colmena.lib.makeHive {
      meta = {
        nixpkgs = pkgs_x86;
        allowApplyAll = false;
      };

      defaults = {
        deployment.targetUser = "root";
        deployment.targetPort = 22;
        deployment.buildOnTarget = true;
      };

      steadfast-dart = {config, ...}: {
        deployment.targetHost = config.networking.hostName;
        deployment.tags = ["local"];
        imports = [self.nixosModules.steadfastDartConfiguration];
      };

      steadfast-defender = {config, ...}: {
        deployment.targetHost = config.networking.hostName;
        deployment.tags = ["local"];
        imports = [self.nixosModules.steadfastDefenderConfiguration];
      };

      # steadfast-noon = {
      #   imports = [self.nixosModules.steadfastNoonConfiguration];
      # };

      mirage-white = {
        deployment.targetHost = "170.64.131.90";
        deployment.tags = ["cloud"];
        imports = [
          self.nixosModules.mirageWhiteConfiguration
          self.nixosModules.mirageWhiteHardware
        ];
      };

      mirage-red = {
        deployment.targetHost = "192.9.184.187";
        deployment.tags = ["cloud"];
        imports = [
          self.nixosModules.mirageRedConfiguration
          self.nixosModules.mirageRedHardware
        ];
      };

      mirage-blue = {
        deployment.targetHost = "137.23.9.31";
        deployment.tags = ["cloud"];
        imports = [
          self.nixosModules.mirageBlueConfiguration
          self.nixosModules.mirageBlueHardware
        ];
      };
    };
}
