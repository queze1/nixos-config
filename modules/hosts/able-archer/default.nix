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
      (self.factory.diskoTmpfsOnRoot
        {device = "/dev/vda";})
      self.nixosModules.preservation
      self.nixosModules.sopsNix

      # UTM VM
      self.nixosModules.utm

      # Build-related
      self.nixosModules.deployNixOnDroid
      self.nixosModules.setupAccessTokens

      # System components
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
      self.nixosModules.resticDefaults
      self.nixosModules.tailscale

      # User related stuff
      self.nixosModules.homeManager
      self.nixosModules.sopsNixWithHM
      self.nixosModules.utmHMIntegration
      self.nixosModules.${mainUser}
      (self.factory.preservationForUser {username = "${mainUser}";})
      (self.factory.utmMountSharedDir {username = "${mainUser}";})
    ];

    my.restic.backups = {
      extraPaths = [
        "/persistent/etc/ssh"
        "/persistent/home/${mainUser}/.ssh"
        "/persistent/home/${mainUser}/Coding"
        "/persistent/home/${mainUser}/cs3231"
        "/persistent/var/lib/tailscale"
      ];
      backblaze-b2 = {};
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

    networking.hostName = hostname;
    system.stateVersion = "25.11";
  };

  flake.nixosConfigurations.able-archer = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.ableArcherConfiguration
      self.nixosModules.ableArcherHardware
    ];
  };
}
