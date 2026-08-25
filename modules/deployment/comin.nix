{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.my.deployment.comin;
in {
  imports = [inputs.comin.nixosModules.comin];

  options.my.deployment.comin.enable = lib.mkEnableOption "Comin";

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
          auth.access_token_path = config.sops.secrets.nix-access-tokens.path;
          poller.period = 15;
        }
      ];
    };

    my.preservation.extraDirectories = ["/var/lib/comin"];
  };
}
