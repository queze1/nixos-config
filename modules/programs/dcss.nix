{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.dcss;
in {
  options.my.programs.dcss.enable = lib.mkEnableOption "Dungeon Crawl Stone Soup";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.crawlTiles];

        my.home.preservation.extraDirectories = [
          ".crawl"
        ];
      })
    ];
  };
}
