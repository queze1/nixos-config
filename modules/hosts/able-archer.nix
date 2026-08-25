{
  config,
  lib,
  pkgs-stable,
  ...
}: let
  cfg = config.my.hosts.able-archer;
  mainUser = "queze";
in {
  options.my.hosts.able-archer.enable =
    lib.mkEnableOption "able-archer host configuration";

  config = lib.mkIf cfg.enable {
    # VM support
    my.utm = {
      enable = true;
      homeManager.enable = true;
      username = mainUser;
    };

    # System config
    my.boot = {
      systemdBoot.enable = true;
      useLatestLtsKernel = true;
      configurationLimit = 10;
    };
    my.sound.enable = true;
    my.fonts.enable = true;
    my.localisation.enable = true;
    my.networkManager.enable = true;
    zramSwap.enable = true;

    # Desktop environment
    my.desktop = {
      enable = true;
      niri.enable = true;
      noctalia.enable = true;
    };

    # Disk configuration
    my.disko.btrfsEphemeralRoot.device = "/dev/vda";
    my.preservation = {
      enable = true;
      users = [mainUser];
    };
    my.btrbk.enable = true;

    # Secret management
    my.sops = {
      enable = true;
      homeManager.enable = true;
    };

    # Services
    my.docker.enable = true;
    my.tailscale.enable = true;

    # User management
    my.homeManager = {
      enable = true;
      pkgsStable = pkgs-stable;
    };
    my.programs.enableAll = true;
    my.users.${mainUser}.enable = true;

    # Personalisation
    my.shellAliases.enable = true;
    my.editor.vim.enable = true;

    # Nix-related config
    my.nix = {
      enable = true;
      settings.download-buffer-size = 5000000;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      binaryCache.enable = true;
      replHistory.enable = true;
      accessTokens.enable = true;
    };

    # Backups
    my.restic = {
      enable = true;
      createRemoteWrapper = true;
      snapshotsDir = "/persistent/snapshots";
      extraPaths = [
        "/etc/ssh"
        "/passwd"
        "/var/lib/nixos"
        "/var/lib/tailscale"

        # Personal folders
        "/home/${mainUser}/Documents"
        "/home/${mainUser}/Desktop"
        "/home/${mainUser}/Music"
        "/home/${mainUser}/Videos"
        "/home/${mainUser}/Coding"
        "/home/${mainUser}/cs3231"
        "/home/${mainUser}/etc/nixos"

        "/home/${mainUser}/.ssh"
        "/home/${mainUser}/.mozilla"
      ];
      extraExclude = [
        ".Trash-1000"
        ".cache"
        ".devenv"
        ".next"
        ".pnpm-store"
        ".venv"
        "node_modules"
      ];
      backups.backblaze-b2 = {
        timerConfig = {
          OnCalendar = "daily";
          RandomizedDelaySec = "1h";
          Persistent = false;
        };
      };
      backups.local-server = {
        timerConfig = {
          OnCalendar = "02:00";
          RandomizedDelaySec = "1h";
          Persistent = false;
        };
      };
      backups.personal-backup = {
        # Managed by Backrest on host machine
        timerConfig = null;
        paths = lib.mkForce [];
      };
    };

    networking.hostName = "able-archer";
    system.stateVersion = "25.11";
  };
}
