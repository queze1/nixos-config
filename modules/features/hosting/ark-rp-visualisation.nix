{inputs, ...}: {
  flake.nixosModules.arkRpVisualisation = {
    config,
    pkgs,
    ...
  }: {
    users.users.ark-rp-viz = {
      isSystemUser = true;
      group = "ark-rp-viz";
    };
    users.groups.ark-rp-viz = {};

    age.secrets.ark-rp-visualisation-env = {
      file = "${inputs.secrets}/ark-rp-visualisation-env.age";
      owner = "ark-rp-viz";
      group = "ark-rp-viz";
    };

    systemd.services.ark-rp-viz = {
      description = "ARK D&D Campaign Dashboard";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${inputs.ark-rp-visualisation.packages.${pkgs.system}.default}/bin/ark-rp-visualisation";
        EnvironmentFile = config.age.secrets.ark-rp-visualisation-env.path;
        User = "ark-rp-viz";
        Group = "ark-rp-viz";
        Restart = "always";

        # Hardening
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };
  };
}
