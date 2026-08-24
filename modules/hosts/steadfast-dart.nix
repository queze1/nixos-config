{
  config,
  lib,
  ...
}: let
  cfg = config.my.hosts.steadfast-dart;
in {
  options.my.hosts.steadfast-dart.enable =
    lib.mkEnableOption "steadfast-dart host configuration";

  # Newer home server
  config = lib.mkIf cfg.enable {
    my.profiles.home-server.enable = true;

    my.podmanContainers.enable = true;

    # Ingress & routing
    my.cloudflared.enable = true;
    my.ddns.enable = true;
    my.tailscaleAuth.enable = true;
    my.caddy = {
      enable = true;
      cloudflareDns.enable = true;
    };

    # Hosted services
    my.apps = {
      autoAssignPorts = true;
      actual.enable = true;
      ark-rp-viz.enable = true;
      forgejo.enable = true;
      github2forgejo.enable = true;
      music-stack.enable = true;
      pihole.enable = true;
      restic-server.enable = true;
      sillytavern.enable = true;
      vaultwarden.enable = true;
    };

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

    networking.hostName = "steadfast-dart";
  };
}
