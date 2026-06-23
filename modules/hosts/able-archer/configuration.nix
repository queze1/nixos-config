{self, ...}: {
  flake.nixosModules.ableArcherConfiguration = {lib, ...}: {
    imports = [
      self.nixosModules.sharedModules
      self.nixosModules.personalBase

      (self.factory.diskoTmpfsOnRoot
        {device = "/dev/vda";})

      self.nixosModules.allPrograms
      self.nixosModules.niriNoctalia

      self.nixosModules.queze
    ];

    host = {
      hypervisor.type = "utm";
      preservation.enable = true;
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
