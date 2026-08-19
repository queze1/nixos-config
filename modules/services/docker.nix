{
  config,
  lib,
  ...
}: let
  cfg = config.my.docker;
in {
  options.my.docker.enable = lib.mkEnableOption "Docker";

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = false;

      rootless = {
        enable = true;
        setSocketVariable = true;
        daemon.settings = {
          dns = [
            "1.1.1.1"
            "8.8.8.8"
          ];
          registry-mirrors = ["https://mirror.gcr.io"];
        };
      };
    };
  };
}
