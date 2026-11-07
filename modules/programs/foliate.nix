{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.foliate;
in {
  options.my.programs.foliate.enable = lib.mkEnableOption "Foliate";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.foliate];

        my.home.preservation.extraDirectories = [
          ".config/com.github.johnfactotum.Foliate"
          ".local/share/com.github.johnfactotum.Foliate"
        ];
      })
    ];
  };
}
