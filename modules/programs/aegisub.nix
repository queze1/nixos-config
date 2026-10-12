{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.aegisub;
in {
  options.my.programs.aegisub.enable = lib.mkEnableOption "Aegisub";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.aegisub];

        my.home.preservation.extraDirectories = [
          ".aegisub"
        ];
      })
    ];
  };
}
