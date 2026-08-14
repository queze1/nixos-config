{
  flake.nixosModules.sharedModules = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;

    # Point legacy <nixpkgs> to this system's nixpkgs
    nix.nixPath = ["nixpkgs=${pkgs.path}"];

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
