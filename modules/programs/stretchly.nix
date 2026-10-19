{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.stretchly;
in {
  options.my.programs.stretchly.enable = lib.mkEnableOption "Stretchly";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.stretchly];

        my.home.preservation.extraDirectories = [
          ".config/Stretchly"
        ];
      })
    ];
  };
}
