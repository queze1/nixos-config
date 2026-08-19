{
  config,
  inputs,
  lib,
  self,
  ...
}: let
  cfg = config.my.homeManager;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];

  options.my.homeManager = {
    enable = lib.mkEnableOption "Home Manager";
    pkgsStable = lib.mkOption {
      type = lib.types.nullOr lib.types.raw;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs self;
        pkgs-stable = cfg.pkgsStable;
      };

      # Import shared options
      sharedModules = [
        ({lib, ...}: {
          options.my.home.preservation.extraDirectories = lib.mkOption {
            type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
            default = [];
            description = "Extra user directories to preserve.";
          };
        })
      ];

      # Backup with an incrementing number
      backupCommand = ''
        filename="$1"
        extension="backup"
        if [ -e "$filename.$extension" ]; then
            count=1
            while [ -e "$filename.$extension.$count" ]; do
                count=$((count + 1))
            done
            mv "$filename" "$filename.$extension.$count"
        else
            mv "$filename" "$filename.$extension"
        fi
      '';
    };
  };
}
