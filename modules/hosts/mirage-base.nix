{self, ...}: let
  sshKeys = import "${self}/ssh-keys.nix";
in {
  flake.nixosModules.mirageBase = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.myOptions

      # System config
      self.nixosModules.openssh
      self.nixosModules.sopsNix
      self.nixosModules.tailscale

      # Nix-related
      self.nixosModules.nixbuild # fallback, but shouldn't need to build

      # Monitoring
      self.nixosModules.beszel
      self.nixosModules.beszelAgent
    ];

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

    # Automatically auth into Tailscale as a server
    services.tailscale = {
      authKeyFile = config.sops.secrets.tailscale-auth-key.path;
      extraUpFlags = ["--hostname=${config.networking.hostName}"];
    };
    sops.secrets.tailscale-auth-key = {};

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
