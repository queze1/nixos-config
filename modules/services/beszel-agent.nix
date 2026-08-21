{
  config,
  lib,
  ...
}: let
  cfg = config.my.beszel-agent;
in {
  options.my.beszel-agent.enable = lib.mkEnableOption "Beszel Agent";

  config = lib.mkIf cfg.enable {
    services.beszel.agent = {
      enable = true;
      smartmon.enable = true;
      environmentFile = config.sops.secrets.beszel-agent-env.path;
      environment = {
        HUB_URL = "https://${config.my.apps.beszel-hub.domain}";
        DISABLE_SSH = "true";
      };
    };

    sops.secrets.beszel-agent-env.restartUnits = ["beszel-agent.service"];
  };
}
