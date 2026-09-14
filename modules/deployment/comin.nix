{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.my.deployment.comin;
in {
  imports = [inputs.comin.nixosModules.comin];

  options.my.deployment.comin = {
    enable = lib.mkEnableOption "comin";
    branch = lib.mkOption {
      type = lib.types.str;
      default = "deployed";
      description = "The branch to deploy from.";
    };
  };

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
          branches.main.name = cfg.branch;
          # Use access token to poll faster
          auth.access_token_path = config.sops.secrets.github-access-token.path;
          poller.period = 10;
        }
      ];
    };

    my.preservation.extraDirectories = ["/var/lib/comin"];
  };
}
