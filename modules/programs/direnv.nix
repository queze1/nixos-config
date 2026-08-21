{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.direnv;
in {
  options.my.programs.direnv.enable = lib.mkEnableOption "direnv" // {default = config.my.programs.enableAll;};

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        programs.direnv = {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          nix-direnv.enable = true;
        };

        my.home.preservation.extraDirectories = [
          ".local/share/direnv"
        ];
      }
    ];
  };
}
