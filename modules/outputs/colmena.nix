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

      defaults = {
        deployment.targetPort = 22;
        deployment.targetUser = "root";
      };

      steadfast-dart = {config, ...}: {
        deployment = {
          buildOnTarget = true;
          targetHost = config.networking.hostName;
        };
        imports = [self.nixosModules.steadfastDartConfiguration];
      };

      steadfast-defender = {config, ...}: {
        deployment = {
          buildOnTarget = true;
          targetHost = config.networking.hostName;
        };
        imports = [self.nixosModules.steadfastDefenderConfiguration];
      };

      # steadfast-noon = {
      #   imports = [self.nixosModules.steadfastNoonConfiguration];
      # };

      mirage-white = {
        deployment = {
          targetHost = "ec2-52-66-130-51.ap-south-1.compute.amazonaws.com";
          sshOptions = [
            "-i"
            "~/.ssh/aws-ec2.pem"
          ];
        };

        imports = [
          self.nixosModules.mirageWhiteConfiguration
          self.nixosModules.mirageWhiteHardware
        ];
      };
    };
}
