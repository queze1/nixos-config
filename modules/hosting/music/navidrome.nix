{
  config,
  lib,
  ...
}: let
  cfg = config.services.navidrome;
  myCfg = config.my.apps.navidrome;
  musicDir = "/srv/music";
in {
  options.my.apps.navidrome = {
    enable = lib.mkEnableOption "Navidrome" // {default = config.my.apps.music-stack.enable;};
    domain = lib.mkOption {
      type = lib.types.str;
      default = "navidrome.osipol.uk";
      description = "Domain to host Navidrome on.";
    };
    socketPath = lib.mkOption {
      type = lib.types.str;
      default = "/run/navidrome/navidrome.sock";
      description = "Socket to run Navidrome on.";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/navidrome";
      description = "Path where Navidrome stores its data.";
    };
  };

  config = lib.mkIf myCfg.enable {
    services.navidrome = {
      enable = true;
      settings = {
        "Address" = "unix:${myCfg.socketPath}";
        "MusicFolder" = musicDir;
        "Scanner.Schedule" = "0 * * * *";
        "Scanner.PurgeMissing" = "always";
        "CoverArtPriority" = "embedded, cover.*, folder.*, front.*, external";
        "PID.Album" = "musicbrainz_albumid|album";
        "Backup.Path" = "${myCfg.dataDir}/backup";
        "Backup.Schedule" = "0 0 * * *";
        "Backup.Count" = 7;
        "ExtAuth.TrustedSources" = "@";
        "ExtAuth.UserHeader" = "X-Webauth-User";
      };
    };

    # Give access to the music dir
    users.users.${cfg.user}.extraGroups = ["music"];

    # Preserve Navidrome data
    my.preservation.extraDirectories = [
      {
        directory = myCfg.dataDir;
        user = cfg.user;
        group = cfg.group;
        mode = "0700";
      }
    ];

    # Back up Navidrome data
    my.restic.extraPaths = [myCfg.dataDir];
    my.restic.extraExclude = ["${myCfg.dataDir}/cache"];

    # Give Caddy access to the socket
    users.users.${config.services.caddy.user}.extraGroups = [cfg.group];

    # Reverse proxy with Tailscale auth
    services.caddy.virtualHosts = {
      ${myCfg.domain} = {
        extraConfig = ''
          import cloudflare_dns
          @protected not path /share/* /ping
          import tailscale_auth @protected
          reverse_proxy unix/${myCfg.socketPath}
        '';
      };
    };
    services.ddclient.domains = [myCfg.domain];
  };
}
