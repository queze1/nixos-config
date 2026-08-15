{
  flake.nixosModules.forgejo2github = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.forgejo;
    myCfg = config.my.apps.forgejo2github;
    source = pkgs.fetchFromGitHub {
      owner = "PatNei";
      repo = "GITHUB2FORGEJO";
      rev = "ac84e6e1a9e0d55a041a1d8e9ba7092eadd85433";
      hash = lib.fakeHash;
    };
  in {
    options.my.apps.forgejo2github = {
      githubUser = lib.mkOption {
        type = lib.types.str;
        default = "queze1";
        description = "GitHub user or organisation to mirror.";
      };
      forgejoUser = lib.mkOption {
        type = lib.types.str;
        default = myCfg.githubUser;
        description = "Forgejo user or organisation that owns the mirrored repositories.";
      };
      strategy = lib.mkOption {
        type = lib.types.enum ["mirror" "clone"];
        default = "mirror";
        description = "Repository migration strategy.";
      };
    };

    config = {
      sops.secrets.forgejo2github-env = {
        owner = cfg.user;
        group = cfg.group;
        mode = "0400";
      };

      systemd.services.forgejo2github = {
        description = "Mirror GitHub repositories to Forgejo";
        after = ["forgejo.service" "network-online.target"];
        wants = ["forgejo.service" "network-online.target"];
        environment = {
          GITHUB_USER = myCfg.githubUser;
          FORGEJO_URL = "https://${config.my.apps.forgejo.domain}";
          FORGEJO_USER = myCfg.forgejoUser;
          STRATEGY = myCfg.strategy;
        };
        path = [pkgs.curl pkgs.jq];
        serviceConfig = {
          ExecStart = "${pkgs.bash}/bin/bash ${source}/github-forgejo-migrate.sh";
          EnvironmentFile = config.sops.secrets.forgejo2github-env.path;
          Type = "oneshot";
          User = cfg.user;
          Group = cfg.group;
        };
      };

      systemd.timers.forgejo2github = {
        description = "Daily GitHub to Forgejo mirror";
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };
    };
  };
}
