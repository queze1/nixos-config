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

    nix.settings = {
      substituters = [
        "https://nix-on-droid.cachix.org"
        "https://noctalia.cachix.org"
      ];
      trusted-public-keys = [
        "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };

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
