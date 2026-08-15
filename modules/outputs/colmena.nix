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
    pkgs_aarch64 = import inputs.nixpkgs-stable {
      system = "aarch64-linux";
      config.allowUnfree = true;
    };
  in
    inputs.colmena.lib.makeHive {
      meta = {
        nixpkgs = pkgs_x86;
        nodeNixpkgs = {
          mirage-white = pkgs_aarch64;
        };
      };

      defaults = {config, ...}: {
        deployment = {
          targetHost = config.networking.hostName;
          targetPort = 22;
          targetUser = "root";
        };
      };

      steadfast-dart = {
        deployment.buildOnTarget = true;
        imports = [self.nixosModules.steadfastDartConfiguration];
      };

      steadfast-defender = {
        deployment.buildOnTarget = true;
        imports = [self.nixosModules.steadfastDefenderConfiguration];
      };

      # steadfast-noon = {
      #   imports = [self.nixosModules.steadfastNoonConfiguration];
      # };

      mirage-white = {
        imports = [
          self.nixosModules.mirageWhiteConfiguration
          self.nixosModules.mirageWhiteHardware
        ];
      };
    };
}
