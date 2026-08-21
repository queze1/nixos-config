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
    services.comin = {
      enable = true;
      remotes = [
        {
          name = "origin";
          url = "https://github.com/queze1/nixos-config.git";
          branches.main.name = "deployed";
        }
      ];
    };

    my.preservation.extraDirectories = ["/var/lib/comin"];
  };
}
