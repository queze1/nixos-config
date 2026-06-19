{inputs, ...}: {
  imports = [
    # Integrate home-manager with flake-parts
    inputs.home-manager.flakeModules.home-manager
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  # For nixd hints
  debug = true;

  systems = [
    "x86_64-linux"
    "x86_64-darwin"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  perSystem = {
    pkgs,
    system,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [inputs.self.overlays.default];
      config.allowUnfree = true;
    };

    # pkgs-stable: Nixpkgs at the latest LTS version
    legacyPackages.pkgs-stable = import inputs.nixpkgs-stable {
      inherit system;
      overlays = [inputs.self.overlays.default];
      config.allowUnfree = true;
    };

    overlayAttrs = {
      # Force Audacity to use Wayland
      audacity = pkgs.symlinkJoin {
        name = "audacity-wayland-fix";
        paths = [pkgs.audacity];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/audacity \
            --set GDK_BACKEND wayland
        '';
      };
    };
  };
}
