{
  config,
  lib,
  ...
}: let
  cfg = config.my.nix.accessTokens;
in {
  options.my.nix.accessTokens.enable = lib.mkEnableOption "Nix access tokens";

  # Use a token with access to the secrets repo if rebuilding locally
  config = lib.mkIf cfg.enable {
    sops.secrets.github-access-token = {};

    sops.templates.nix-access-tokens = {
      content = "access-tokens = github.com=${config.sops.placeholder.github-access-token}";
      mode = "0440";
      group = "wheel"; # give access to sudoers
    };

    nix.extraOptions = ''
      !include ${config.sops.templates.nix-access-tokens.path}
    '';
  };
}
