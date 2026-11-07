{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.kdenlive;
in {
  options.my.programs.kdenlive.enable = lib.mkEnableOption "Kdenlive";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.kdePackages.kdenlive];

        my.home.preservation.extraDirectories = [
          ".cache/kdenlive"
          ".cache/stalefiles/kdenlive"
          ".local/share/kdenlive"
          ".local/share/kxmlgui5/kdenlive"
          ".local/share/knewstuff3"
        ];

        my.home.preservation.extraFiles = [".config/kdenliverc"];
      })
    ];
  };
}
