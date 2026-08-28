{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}: let
  cfg = config.my.profiles.home-server;
  hostname = config.networking.hostName;
  sshKeys = import "${self}/ssh-keys.nix";
in {
  options.my.profiles.home-server.enable = lib.mkEnableOption "home server profile";

  config = lib.mkIf cfg.enable {
    # Base configuration for home servers
    # System config
    my.boot = {
      systemdBoot.enable = true;
      useLatestLtsKernel = true;
      configurationLimit = 3;
    };
    my.localisation.enable = true;
    my.networkManager = {
      enable = true;
      homeWifi.enable = true;
    };
    zramSwap.enable = true;

    # Disk configuration
    my.disko.btrfsEphemeralRoot.device = "/dev/vda";
    my.preservation.enable = true;
    my.btrbk.enable = true;

    # Secret management
    my.sops.enable = true;

    # Services
    my.beszel-agent.enable = true;
    my.fwupd.enable = true;
    my.openssh.enable = true;
    my.tailscale = {
      enable = true;
      useAuthKey = true;
      openSSHOnTailscale = true;
    };

    # Nix-related config
    my.deployment.comin.enable = true;
    my.nix = {
      enable = true;
      settings.download-buffer-size = 5000000;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      binaryCache.enable = true;
      accessTokens.enable = true;
    };

    # Personalisation
    my.editor.vim.enable = true;

    # Convenience programs
    environment.systemPackages = [
      pkgs.btop
      pkgs.tree
    ];

    # User management & security
    my.users.commander.enable = true;
    users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];
    security.sudo.wheelNeedsPassword = false;

    # Don't sleep on lid close
    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };

    # Preserve battery health
    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 60;
        START_CHARGE_THRESH_BAT1 = 40;
        STOP_CHARGE_THRESH_BAT1 = 60;
      };
    };

    # Turn off monitor after 1 minute idle
    boot.kernelParams = ["consoleblank=60"];

    hardware.facter.reportPath = "${inputs.secrets}/facter/${hostname}.json";
    system.stateVersion = "25.11";
  };
}
