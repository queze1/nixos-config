{
  config,
  lib,
  ...
}: let
  cfg = config.my.hosts.steadfast-defender;
in {
  options.my.hosts.steadfast-defender.enable =
    lib.mkEnableOption "steadfast-defender host configuration";

  # ThinkPad home server
  config = lib.mkIf cfg.enable {
    my.profiles.home-server.enable = true;
    my.profiles.home-server.bootstrap = true;

    # Ingress & routing
    my.ddns.enable = true;
    my.caddy = {
      enable = true;
      cloudflareDns.enable = true;
    };
    my.tailscaleAuth.enable = true;

    # Hosted services
    my.apps = {
      autoAssignPorts = true;
      attic.enable = true;
      immich.enable = true;
      paperless.enable = true;
      restic-server.enable = true;
    };

    # Backups
    my.restic = {
      enable = true;
      snapshotsDir = "/persistent/snapshots";
      extraPaths = [
        "/etc/ssh"
        "/var/lib/nixos"
        "/var/lib/tailscale"
      ];
      backups.backblaze-b2 = {
        timerConfig = {
          OnCalendar = "daily";
          RandomizedDelaySec = "4h";
          Persistent = true;
        };
      };
      backups.local-server = {
        timerConfig = {
          OnCalendar = "hourly";
          RandomizedDelaySec = "15m";
          Persistent = true;
        };
      };
    };

    networking.hostName = "steadfast-defender";
  };
}
