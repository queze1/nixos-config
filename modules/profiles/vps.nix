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
  options.my.profiles.vps = {
    enable = lib.mkEnableOption "VPS profile";
    bootstrap = lib.mkEnableOption "settings useful for bootstrapping";
  };

  config = lib.mkIf cfg.enable {
    # Secret management
    my.sops.enable = true;

    # Services
    my.openssh = {
      enable = true;
      openFirewall = cfg.bootstrap;
    };
    my.tailscale = {
      enable = true;
      useAuthKey = true;
      setHostname = true;
      extraUpFlags = ["--ssh"]; # use Tailscale SSH
    };
    my.deployment.system-puller.enable = true;

    # Monitoring
    my.beszel-agent.enable = true;

    # Helper programs
    environment.systemPackages = with pkgs; [
      htop
      ncdu
      ssh-to-age
    ];

    # Allow SSH into root
    users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];

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
    my.localisation.enable = true;

    system.stateVersion = "26.05";
  };
}
