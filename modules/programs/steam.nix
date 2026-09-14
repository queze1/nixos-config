{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.steam;
in {
  options.my.programs.steam.enable = lib.mkEnableOption "Steam";

  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;

    my.preservation.extraUserDirectories = [
      ".local/share/Steam"
      ".steam"
    ];
  };
}
