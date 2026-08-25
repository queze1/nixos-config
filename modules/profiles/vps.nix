{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  cfg = config.my.profiles.vps;
  sshKeys = import "${self}/ssh-keys.nix";
in {
  options.my.profiles.vps.enable = lib.mkEnableOption "VPS profile";

  config = lib.mkIf cfg.enable {
    # Secret management
    my.sops.enable = true;
    my.deployment.system-puller.enable = true;

    # Services
    my.beszel-agent.enable = true;
    my.openssh.enable = true;
    my.tailscale = {
      enable = true;
      autoAuth = true;
      setHostname = true;
    };

    # Helper programs
    environment.systemPackages = with pkgs; [
      htop
      ncdu
      ssh-to-age
    ];

    # Allow SSH into root
    users.users.root.openssh.authorizedKeys.keys = [
      sshKeys.ableArcherKey
      sshKeys.colmenaGHAKey
    ];

    zramSwap = {
      enable = true;
      memoryPercent = 100;
    };

    # Minimise Nix store usage
    my.boot.configurationLimit = 3;
    documentation.enable = false;
    my.nix = {
      enable = true;
      binaryCache.enable = true;
      settings.auto-optimise-store = true;
      gc = {
        automatic = true;
        options = "--delete-old";
      };
    };

    environment.etc = {
      "test".text = "test";
    };

    system.stateVersion = "26.05";
  };
}
