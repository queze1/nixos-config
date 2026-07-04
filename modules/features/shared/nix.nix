{
  flake.nixosModules.sharedModules = {
    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = ["nix-command" "flakes"];
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
