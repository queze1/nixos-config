{
  config,
  lib,
  ...
}: let
  cfg = config.my.setupAccessTokens;
in {
  options.my.setupAccessTokens.enable = lib.mkEnableOption "Nix access tokens";

  config = lib.mkIf cfg.enable {
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
