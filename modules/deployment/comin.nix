{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.my.deployment.comin;
in {
  imports = [inputs.comin.nixosModules.comin];

  options.my.deployment.comin.enable = lib.mkEnableOption "comin";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.my.nix.accessTokens.enable;
        message = "comin requires Nix access tokens";
      }
    ];

    services.comin = {
      enable = true;
      remotes = [
        {
          name = "origin";
          url = "https://github.com/queze1/nixos-config.git";
          branches.main.name = "deployed";
          # Use access token to poll faster
          auth.access_token_path = config.sops.secrets.github-access-token.path;
          poller.period = 15;
        }
      ];
    };

    my.preservation.extraDirectories = ["/var/lib/comin"];
  };
}
