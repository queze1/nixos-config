{
  config,
  lib,
  pkgs,
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
    my.apps.beszel-hub.enable = true;

    # Backups
    my.restic = {
      enable = true;
      backups.backblaze-b2 = {
        user = "root";
        backupPrepareCommand = ''
          if ${pkgs.systemd}/bin/systemctl is-active --quiet beszel-hub.service; then
            touch /run/restic-backups-backblaze-b2/beszel-hub-was-active
            ${pkgs.systemd}/bin/systemctl stop beszel-hub.service
          fi
        '';
        backupCleanupCommand = ''
          if [ -e /run/restic-backups-backblaze-b2/beszel-hub-was-active ]; then
            ${pkgs.systemd}/bin/systemctl start beszel-hub.service
            rm -f /run/restic-backups-backblaze-b2/beszel-hub-was-active
          fi
        '';
        timerConfig = {
          OnCalendar = "daily";
          RandomizedDelaySec = "4h";
          Persistent = true;
        };
      };
    };

    networking.hostName = "mirage-blue";
  };
}
