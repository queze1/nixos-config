{self, ...}: let
  sshKeys = import "${self}/ssh-keys.nix";
in {
  flake.nixosModules.mirageBase = {pkgs, ...}: {
    imports = [
      # Monitoring
      self.nixosModules.beszel
      self.nixosModules.beszelAgent
    ];

    # Secret management
    my.sops.enable = true;

    # Services
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
      settings.auto-optimise-store = true;
      gc = {
        automatic = true;
        options = "--delete-old";
      };
    };

    system.stateVersion = "26.05";
  };
}
