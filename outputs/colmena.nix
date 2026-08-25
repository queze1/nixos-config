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
    commonModules = inputs.import-tree ../modules;
  in
    inputs.colmena.lib.makeHive {
      meta = {
        nixpkgs = pkgs_x86;
        allowApplyAll = false;
        specialArgs = {
          inherit inputs self;
          sources = import ../npins;
        };
      };

      defaults = {
        imports = [commonModules];

        deployment = {
          targetUser = "root";
          targetPort = 22;
          buildOnTarget = true;
        };
      };

      steadfast-dart = {config, ...}: {
        deployment.targetHost = config.networking.hostName;
        deployment.tags = ["local"];
        imports = [{my.hosts.steadfast-dart.enable = true;}];
      };

      steadfast-defender = {config, ...}: {
        deployment.targetHost = config.networking.hostName;
        deployment.tags = ["local"];
        imports = [{my.hosts.steadfast-defender.enable = true;}];
      };

      # steadfast-noon = {
      #   imports = [self.nixosModules.steadfastNoonConfiguration];
      # };

      # mirage-white = {
      #   deployment.targetHost = "170.64.131.90";
      #   deployment.tags = ["cloud"];
      #   imports = [
      #     self.nixosModules.mirageWhiteConfiguration
      #     self.nixosModules.mirageWhiteHardware
      #   ];
      # };

      mirage-red = {
        deployment.targetHost = "192.9.184.187";
        deployment.tags = ["cloud"];
        imports = [
          {my.hosts.mirage-red.enable = true;}
          (import ../modules/hosts/_hardware/mirage-red.nix)
        ];
      };

      mirage-blue = {
        deployment.targetHost = "137.23.9.31";
        deployment.tags = ["cloud"];
        imports = [
          {my.hosts.mirage-blue.enable = true;}
          (import ../modules/hosts/_hardware/mirage-blue.nix)
        ];
      };
    };

  # Export Colmena from the flake input
  perSystem = {inputs', ...}: {
    packages.colmena = inputs'.colmena.packages.colmena;
  };
}
