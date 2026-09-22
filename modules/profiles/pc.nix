{
  config,
  lib,
  pkgs-stable,
  ...
}: let
  cfg = config.my.profiles.pc;
  mainUser = "queze";
in {
  options.my.profiles.pc = {
    enable = lib.mkEnableOption "PC profile";
    bootstrap = lib.mkEnableOption "settings useful for bootstrapping";
  };

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
    my.programs.enableDefault = true;
    my.users.${mainUser}.enable = true;

    # Personalisation
    my.shortcuts.enable = true;
    my.editor.vim.enable = true;

    # Nix-related settings
    my.nix = {
      enable = true;
      settings.download-buffer-size = 5000000;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      binaryCache.enable = !cfg.bootstrap;
      replHistory.enable = true;
      accessTokens.enable = true;
    };

    my.restic = {
      createRemoteWrapper = true;
      extraPaths = [
        "/etc/ssh"
        "/passwd"
        "/var/lib/nixos"
        "/home/${mainUser}/Documents"
        "/home/${mainUser}/Desktop"
        "/home/${mainUser}/Music"
        "/home/${mainUser}/Videos"
        "/home/${mainUser}/Coding"
        "/home/${mainUser}/etc/nixos"
        "/home/${mainUser}/.config/sops/age"
        "/home/${mainUser}/.ssh"

        "/home/${mainUser}/.local/share/Paradox Interactive/Europa Universalis IV/save games"
        "/home/${mainUser}/.local/share/Paradox Interactive/Europa Universalis IV/Screenshots"
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
    };
  };
}
