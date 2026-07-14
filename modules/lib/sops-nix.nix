{
  flake.nixosModules.sops-nix = {
    my.preservation.extraUserDirectories = [".config/sops/age"];
  };
}
