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

    # Minimise Nix store size
    boot.loader.grub.configurationLimit = 3;
    nix.gc = {
      automatic = true;
      options = "--delete-old";
    };
    nix.settings.auto-optimise-store = true;
    documentation.enable = false;

    nix.settings.experimental-features = ["nix-command" "flakes"];

    system.stateVersion = "26.05";
  };
}
