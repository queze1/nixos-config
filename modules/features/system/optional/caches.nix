{
  flake.nixosModules.caches = {
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
  };
}
