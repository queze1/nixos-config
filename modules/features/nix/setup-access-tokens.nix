{
  flake.nixosModules.setupAccessTokens = {config, ...}: {
    # Needed to access the secrets GitHub repo
    sops.secrets.nix-access-tokens = {
      mode = "0440";
      group = "wheel"; # give access to sudoers
    };
    nix.extraOptions = ''
      !include ${config.sops.secrets.nix-access-tokens.path}
    '';
  };
}
