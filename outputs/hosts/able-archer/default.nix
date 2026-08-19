{
  inputs,
  self,
  ...
}: let
  hostname = "able-archer";
in {
  flake.nixosModules.ableArcherConfiguration = {
    lib,
    pkgs-stable,
    ...
  }: let
    mainUser = "queze";
  in {
    imports = [
      self.nixosModules.sharedModules

      # UTM VM
      self.nixosModules.utm

      # Build-related
      self.nixosModules.setupAccessTokens

      # Services
      self.nixosModules.btrbk
      self.nixosModules.docker
      self.nixosModules.resticDefaults
      self.nixosModules.tailscale

      # Desktop environment
      self.nixosModules.niriNoctalia

      # Programs
      self.nixosModules.allPrograms

      # User related stuff
      self.nixosModules.utmHMIntegration
      (self.factory.utmMountSharedDir {username = "${mainUser}";})
    ];

    # System options
    my.disko.btrfsEphemeralRoot.device = "/dev/vda";
    my.fonts.enable = true;
    my.homeManager = {
      enable = true;
      pkgsStable = pkgs-stable;
    };
    my.preservation = {
      enable = true;
      users.${mainUser}.enable = true;
    };
    my.users.${mainUser}.enable = true;
    my.shellAliases.enable = true;
    my.sound.enable = true;
    my.sops = {
      enable = true;
      homeManager.enable = true;
    };

    my.restic = {
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

    # Save space
    nix.gc.options = lib.mkForce "--delete-older-than 7d";

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
