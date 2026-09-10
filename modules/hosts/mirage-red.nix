{
  config,
  lib,
  pkgs,
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

    environment.systemPackages = [
      (pkgs.writeShellScriptBin
        "my-script" ''
          echo "If you're seeing this, it means the deployment worked."
        '')
    ];

    networking.hostName = "mirage-red";
  };
}
