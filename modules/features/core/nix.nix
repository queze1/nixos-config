{inputs, ...}: {
  flake.nixosModules.nix = {
    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Activate overlays
    nixpkgs.overlays = [inputs.self.overlays.default];

    # Enable flakes
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    nix.settings = {
      download-buffer-size = 524288000; # 500 MiB
    };
  };
}
