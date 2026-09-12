{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.cloudflaredClient;
in {
  options.my.programs.cloudflaredClient.enable = lib.mkEnableOption "cloudflared client" // {default = config.my.programs.enableAll;};

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.cloudflared];

        my.home.preservation.extraDirectories = [".cloudflared"];
      })
    ];
  };
}
