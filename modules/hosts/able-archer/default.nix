{
  inputs,
  self,
  ...
}: let
  hostname = "able-archer";
in {
  flake.nixosModules.ableArcherConfiguration = {lib, ...}: let
    mainUser = "queze";
  in {
    imports = [
      self.nixModules.myOptions
      self.nixosModules.sharedModules

      # Basic libraries
      (self.factory.diskoBrtfsEphemeralRoot
        {device = "/dev/vda";})
      self.nixosModules.preservation
      self.nixosModules.sopsNix

      # UTM VM
      self.nixosModules.utm

      # Build-related
      self.nixosModules.setupAccessTokens

      # System components
      self.nixosModules.fonts
      self.nixosModules.networkmanager
      self.nixosModules.shellAliases
      self.nixosModules.sound

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
      self.nixosModules.homeManager
      self.nixosModules.sopsNixWithHM
      self.nixosModules.utmHMIntegration
      self.nixosModules.${mainUser}
      (self.factory.preservationForUser {username = "${mainUser}";})
      (self.factory.utmMountSharedDir {username = "${mainUser}";})
    ];

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

  flake.nixosConfigurations.able-archer = let
    pkgs-stable = import inputs.nixpkgs-stable {
      system = "aarch64-linux";
      allowUnfree = true;
    };
  in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit pkgs-stable;};

      modules = [
        self.nixosModules.ableArcherConfiguration
        self.nixosModules.ableArcherHardware
      ];
    };
}
