{
  flake.nixosModules.nix = {
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
