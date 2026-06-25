{self, ...}: {
  flake.nixosModules.ableArcherConfiguration = {lib, ...}: {
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

      self.nixosModules.personalBase

      self.nixosModules.allPrograms
      self.nixosModules.niriNoctalia

      # Services
      self.nixosModules.docker
      self.nixosModules.tailscale

      self.nixosModules.queze
    ];

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
