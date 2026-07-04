{self, ...}: {
  flake.nixosModules.ableArcherConfiguration = {lib, ...}: let
    mainUser = "queze";
  in {
    imports = [
      self.nixosModules.myOptions
      self.nixosModules.sharedModules

      # Basic libraries
      self.nixosModules.agenix
      self.nixosModules.preservation
      (self.factory.diskoTmpfsOnRoot
        {device = "/dev/vda";})

      # UTM VM
      self.nixosModules.utm

      # System components
      self.nixosModules.deployNixOnDroid
      self.nixosModules.fonts
      self.nixosModules.networkmanager
      self.nixosModules.shellAliases
      self.nixosModules.sound

      # Desktop environment
      self.nixosModules.niriNoctalia

      # Programs
      self.nixosModules.allPrograms

      # Services
      self.nixosModules.docker
      self.nixosModules.syncthing
      self.nixosModules.tailscale

      # User related stuff
      self.nixosModules.homeManager
      self.nixosModules.agenixForHM
      self.nixosModules.utmHMIntegration
      self.nixosModules.${mainUser}
      (self.factory.preservationForUser {username = "${mainUser}";})
      (self.factory.utmMountSharedDir {username = "${mainUser}";})
    ];

    # Auto-update from Github repo
    system.autoUpgrade = {
      enable = true;
      flake = "github:queze/nixos-config";
    };

    # Sync this PC with phone home server
    services.syncthing = {
      user = "${mainUser}";
      group = "users";
      dataDir = "/home/${mainUser}/.local/share/syncthing";
      configDir = "/home/${mainUser}/.config/syncthing";
      settings = {
        devices = {
          "poco-x3-pro" = {
            id = "CGN4GSA-JX3232W-WM5XXI6-RKU3W6F-RVAZH7N-YPOCAF3-52SRDUO-HHRFFQI";
            addresses = [
              "tcp://100.102.46.127:22000"
            ];
          };
        };
        folders = {
          "SillyTavern Data" = {
            id = "nicrf-adfwa";
            path = "/mnt/utm/Apps/SillyTavern-Launcher/SillyTavern/data/default-user";
            devices = ["poco-x3-pro"];
          };
          "Music" = {
            id = "ft74r-2c4sc";
            path = "/mnt/utm/Music";
            devices = ["poco-x3-pro"];
          };
        };
      };
    };

    # Force Audacity to use Wayland
    nixpkgs.overlays = [
      # deadnix: skip
      (final: prev: {
        audacity = prev.symlinkJoin {
          name = "audacity-wayland-fix";
          paths = [prev.audacity];
          nativeBuildInputs = [prev.makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/audacity \
              --set GDK_BACKEND wayland
          '';
        };
      })
    ];

    # Save space
    nix.gc.options = lib.mkForce "--delete-older-than 7d";
    boot.loader.systemd-boot.configurationLimit = lib.mkForce 10;

    networking.hostName = "able-archer";
    system.stateVersion = "25.11";
  };
}
