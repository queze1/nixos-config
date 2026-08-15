{
  inputs,
  pkgs-stable_x86,
  self,
  ...
}: {
  flake.colmenaHive = inputs.colmena.lib.makeHive {
    meta = {
      nixpkgs = pkgs-stable_x86;
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

    # mirage-white = {
    #   imports = [self.nixosModules.mirageWhiteConfiguration];
    # };
  };
}
