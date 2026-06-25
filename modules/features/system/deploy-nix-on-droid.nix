{self, ...}: {
  flake.nixosModules.deployNixOnDroid = {pkgs, ...}: {
    # Add substituter to build a Nix-on-Droid configuration
    nix.settings = {
      substituters = [
        "https://nix-on-droid.cachix.org"
      ];
      trusted-public-keys = [
        "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
      ];
    };

    environment.systemPackages = [
      self.packages.${pkgs.system}.deploy-nix-on-droid
    ];
  };
}
