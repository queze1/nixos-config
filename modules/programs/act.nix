{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.act;
in {
  options.my.programs.act.enable = lib.mkEnableOption "act";

  # TODO: Add act with Podman
  config =
    lib.mkIf cfg.enable {
    };
}
