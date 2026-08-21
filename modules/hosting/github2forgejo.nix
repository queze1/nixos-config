{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.forgejo;
  myCfg = config.my.apps.github2forgejo;
  source = pkgs.fetchFromGitHub {
    owner = "PatNei";
    repo = "GITHUB2FORGEJO";
    rev = "ac84e6e1a9e0d55a041a1d8e9ba7092eadd85433";
    hash = "sha256-E4j8PvIjVqVLc08fi3TLJjzVJ4YSeyAnd2ry639SxSg=";
  };
in {
  options.my.apps.github2forgejo = {
    enable = lib.mkEnableOption "GitHub to Forgejo mirroring";
    githubUser = lib.mkOption {
      type = lib.types.str;
      default = "queze1";
      description = "GitHub user or organisation to mirror.";
    };
    strategy = lib.mkOption {
      type = lib.types.enum ["mirror" "clone"];
      default = "mirror";
      description = "Repository migration strategy.";
    };
  };

  config = lib.mkIf myCfg.enable {
    sops.secrets.github2forgejo-env = {
      owner = cfg.user;
      group = cfg.group;
      mode = "0400";
    };

    systemd.services.github2forgejo = {
      description = "Mirror GitHub repositories to Forgejo";
      after = ["forgejo.service" "network-online.target"];
      wants = ["forgejo.service" "network-online.target"];
      environment = {
        GITHUB_USER = myCfg.githubUser;
        FORGEJO_URL = "https://${config.my.apps.forgejo.domain}";
        STRATEGY = myCfg.strategy;
      };
      path = [
        pkgs.bash
        pkgs.curl
        pkgs.jq
        pkgs.ncurses
      ];
      serviceConfig = {
        ExecStart = "${pkgs.bash}/bin/bash ${source}/github-forgejo-migrate.sh";
        EnvironmentFile = config.sops.secrets.github2forgejo-env.path;
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.group;
      };
    };

    systemd.timers.github2forgejo = {
      description = "Daily GitHub to Forgejo mirror";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
    };
  };
}
