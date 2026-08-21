{
  inputs,
  self,
  ...
}: let
  hostname = "able-archer";
in {
  flake.nixosModules.ableArcherConfiguration = {pkgs-stable, ...}: let
    mainUser = "queze";
  in {
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
      snapshotsDir = "/persistent/snapshots";
      extraPaths = [
        "/etc/ssh"
        "/home/${mainUser}/.ssh"
        "/home/${mainUser}/Coding"
        "/home/${mainUser}/cs3231"
        "/home/${mainUser}/etc/nixos"
        "/passwd"
        "/var/lib/tailscale"
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
    };

    networking.hostName = hostname;
    system.stateVersion = "25.11";
  };

  flake.nixosConfigurations.able-archer = self.factory.mkNixosSystem {
    nixpkgs = inputs.nixpkgs;
    system = "aarch64-linux";
    modules = [
      self.nixosModules.ableArcherConfiguration
      self.nixosModules.ableArcherHardware
    ];
    extraPkgs.pkgs-stable = inputs.nixpkgs-stable;
  };
}
