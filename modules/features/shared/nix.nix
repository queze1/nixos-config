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
  };
}
