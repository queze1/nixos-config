{
  config,
  lib,
  ...
}: let
  cfg = config.my.hosts.mirage-blue;
in {
  options.my.hosts.mirage-blue.enable =
    lib.mkEnableOption "mirage-blue host configuration";

  # 512mb Oracle Cloud instance
  config = lib.mkIf cfg.enable {
    my.profiles.vps.enable = true;

    my.caddy = {
      enable = true;
      cloudflareDns.enable = true;
    };
    my.ddns.enable = true;
    my.tailscaleAuth.enable = true;

    # Hosted services
    my.apps = {
      beszel-hub.enable = true;
      vaultwarden.enable = true;
    };

    # Backups
    my.restic = {
      enable = true;
      backups.backblaze-b2 = {
        restartServices = [
          "beszel-hub.service"
          "vaultwarden.service"
        ];
        timerConfig = {
          OnCalendar = "*-*-* */4:00:00"; # every 4 hours
          RandomizedDelaySec = "1h";
          Persistent = true;
        };
      };
    };

    networking.hostName = "mirage-blue";
  };
}
