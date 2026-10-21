{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.obs;
in {
  options.my.programs.obs.enable = lib.mkEnableOption "OBS Studio";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.obs-studio];

        my.home.preservation.extraDirectories = [
          ".config/obs-studio"
        ];
      })
    ];
  };
}
