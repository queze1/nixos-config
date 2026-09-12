{
  config,
  lib,
  pkgs-stable,
  ...
}: let
  cfg = config.my.hosts.iron-hammer;
  mainUser = "queze";
in {
  options.my.hosts.iron-hammer.enable =
    lib.mkEnableOption "iron-hammer host configuration";

  config = lib.mkIf cfg.enable {
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
    my.disko = {
      profile = "btrfsEphemeralRoot";
      device = "/dev/vda";
    };
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
    my.tailscale.enable = true;

    # User management
    my.homeManager = {
      enable = true;
      pkgsStable = pkgs-stable;
    };
    my.programs.enableAll = true;
    my.users.${mainUser}.enable = true;

    # Personalisation
    my.shortcuts.enable = true;
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

    # TODO: Add backups

    networking.hostName = "iron-hammer";
    system.stateVersion = "26.11";
  };
}
