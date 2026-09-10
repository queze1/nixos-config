{
  config,
  lib,
  ...
}: let
  cfg = config.my.hosts.mirage-red;
in {
  options.my.hosts.mirage-red.enable =
    lib.mkEnableOption "mirage-red host configuration";

  # 512mb Oracle Cloud instance
  config = lib.mkIf cfg.enable {
    my.profiles.vps.enable = true;

    my.cloudflared.enable = true;
    my.apps.gatus.enable = true;

    networking.hostName = "mirage-red";
  };
}
