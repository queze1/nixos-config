{
  flake.nixosModules.setupAccessTokens = {config, ...}: {
    # Only needed for machines that will be building
    sops.secrets.nix-access-tokens = {};
    nix.extraOptions = ''
      !include ${config.sops.secrets.nix-access-tokens.path}
    '';
  };
}
