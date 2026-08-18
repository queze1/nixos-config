{
  flake.nixosModules.sharedModules = {
    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      download-buffer-size = 5000000; # 500 MB
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Preserve nix repl history
    my.preservation.extraUserDirectories = [
      ".local/state/nix"
    ];

    # Use my binary cache
    nix.settings = {
      substituters = [
        "https://attic.osipol.uk/cache"
      ];
      trusted-public-keys = [
        "cache:C3spwmruXebNeOwAnYy98JGgTOnos586oMVmkYn/RYg="
      ];
    };
  };
}
