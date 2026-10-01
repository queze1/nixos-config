{
  config,
  lib,
  ...
}: let
  cfg = config.my.hosts.able-archer;
in {
  options.my.hosts.able-archer.enable =
    lib.mkEnableOption "able-archer host configuration";

  config = lib.mkIf cfg.enable {
    my.profiles.pc.enable = true;

    my.syncthing = {
      devices.iron-hammer = {
        id = "BN67OOS-VSHGU2Y-BXR5JP2-KO4XJ7A-IEADNTQ-XC7XVHN-ASHDRTB-4WJM6Q3";
        addresses = ["tcp://100.104.155.85:22000"];
      };
      folders.media = {
        id = "media";
        label = "Media";
        path = "/home/queze/Documents/Media";
        devices = ["iron-hammer"];
      };
    };

    # VM support
    my.utm = {
      enable = true;
      homeManager.enable = true;
      username = "queze";
    };

    # Disk configuration
    my.disko = {
      profile = "btrfsEphemeralRoot";
      device = "/dev/vda";
    };
    my.preservation = {
      enable = true;
      users = ["queze"];
    };
    my.btrbk.enable = true;

    virtualisation.docker.rootless.enable = true;

    # Programs
    my.programs = {
      bitwarden.enable = true;
      direnv.enable = true;
      fish.enable = true;
      firefox = {
        enable = true;
        useLegacyDefault = true;
      };
      foot.enable = true;
      git.enable = true;
      immichGo.enable = true;
      imv.enable = true;
      llmTools.enable = true;
      nvf.enable = true;
      obsidian.enable = true;
      vesktop.enable = true;
      yazi.enable = true;
    };

    # Backups
    my.restic = {
      enable = true;
      snapshotsDir = "/persistent/snapshots";
      backups = {
        backblaze-b2 = {
          timerConfig = {
            OnCalendar = "daily";
            RandomizedDelaySec = "1h";
            Persistent = false;
          };
        };
        steadfast-defender = {
          timerConfig = {
            OnCalendar = "02:00";
            RandomizedDelaySec = "1h";
            Persistent = false;
          };
        };
        steadfast-dart = {
          timerConfig = {
            OnCalendar = "02:00";
            RandomizedDelaySec = "1h";
            Persistent = false;
          };
        };
        personal-backup = {
          # Managed by Backrest on host machine
          timerConfig = null;
          paths = lib.mkForce [];
        };
      };
    };

    networking.hostName = "able-archer";
    system.stateVersion = "25.11";
  };
}
