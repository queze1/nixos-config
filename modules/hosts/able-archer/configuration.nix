{self, ...}: {
  flake.nixosModules.ableArcherConfiguration = {
    imports = [
      self.nixosModules.coreFeatures
      self.nixosModules.optionalFeatures

      self.nixosModules.allPrograms
      self.nixosModules.niriNoctalia

      self.nixosModules.queze
    ];

    host = {
      hypervisor.type = "utm";
      disko.profile = "hybrid-tmpfs-on-root";
      preservation.enable = true;
    };

    # Force Audacity to use Wayland
    nixpkgs.overlays = [
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

    networking.hostName = "able-archer";
    system.stateVersion = "25.11";
  };
}
