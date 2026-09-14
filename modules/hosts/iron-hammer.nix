{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.my.hosts.iron-hammer;
in {
  options.my.hosts.iron-hammer.enable =
    lib.mkEnableOption "iron-hammer host configuration";

  config = lib.mkIf cfg.enable {
    my.profiles.pc.enable = true;

    # Disk configuration
    my.disko = {
      profile = "btrfsEphemeralRoot";
      useFacterDevice = true;
    };
    my.preservation = {
      enable = true;
      users = ["queze"];
    };
    my.btrbk.enable = true;

    # Services
    my.deployment.comin.enable = true;
    my.beszel-agent.enable = true;

    # Programs
    my.programs = {
      bitwarden.enable = true;
      direnv.enable = true;
      firefox.enable = true;
      fish.enable = true;
      foot.enable = true;
      git.enable = true;
      imv.enable = true;
      llmTools.enable = true;
      nvf.enable = true;
      obsidian.enable = true;
      steam.enable = true;
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
            RandomizedDelaySec = "4h";
            Persistent = true;
          };
        };
        local-server = {
          timerConfig = {
            OnCalendar = "hourly";
            RandomizedDelaySec = "15m";
            Persistent = true;
          };
        };
        local-server2 = {
          timerConfig = {
            OnCalendar = "hourly";
            RandomizedDelaySec = "15m";
            Persistent = true;
          };
        };
      };
    };

    networking.hostName = "iron-hammer";
    hardware.facter.reportPath = "${inputs.secrets}/facter/iron-hammer.json";
    system.stateVersion = "26.11";
  };
}
