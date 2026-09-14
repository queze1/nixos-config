{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.obsidian;
in {
  options.my.programs.obsidian.enable = lib.mkEnableOption "Obsidian";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.obsidian];

        my.home.preservation.extraDirectories = [
          ".config/obsidian"
        ];
      })
    ];
  };
}
