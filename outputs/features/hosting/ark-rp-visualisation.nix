{inputs, ...}: {
  flake.nixosModules.arkRpVisualisation = {
    config,
    lib,
    pkgs,
    ...
  }: let
    myCfg = config.my.apps.ark-rp-viz;
  in {
    options.my.apps.ark-rp-viz = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "ark-rp-visualisation.osipol.uk";
        description = "Domain to host ark-rp-visualisation on.";
      };
      port = lib.mkOption {
        type = lib.types.int;
        default = 8050;
        description = "Port to run ark-rp-visualisation on.";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/ark-rp-viz";
        description = "Path where ark-rp-visualisation stores its data.";
      };
    };

    config = {
      users.users.ark-rp-viz = {
        isSystemUser = true;
        group = "ark-rp-viz";
        home = myCfg.dataDir;
      };
      users.groups.ark-rp-viz = {};

      # Preserve ark-rp-visualisation data
      my.preservation.extraDirectories = [
        {
          directory = myCfg.dataDir;
          user = "ark-rp-viz";
          group = "ark-rp-viz";
          mode = "0700";
        }
      ];

      sops.secrets.ark-rp-visualisation-env = {
        owner = "ark-rp-viz";
        group = "ark-rp-viz";
        restartUnits = ["ark-rp-viz.service"];
      };

      # Service to run ark-rp-visualisation
      systemd.services.ark-rp-viz = {
        description = "ARK D&D Campaign Dashboard";
        after = [
          "network.target"
        ];
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          ExecStart = "${inputs.ark-rp-visualisation.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/ark-rp-visualisation";
          User = "ark-rp-viz";
          Group = "ark-rp-viz";
          Restart = "always";

          Environment = ''
            PORT=${toString myCfg.port}
          '';
          EnvironmentFile = config.sops.secrets.ark-rp-visualisation-env.path;

          # Hardening
          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          NoNewPrivileges = true;
          StateDirectory = "ark-rp-viz";
        };
      };

      # Networking with Cloudflare tunnel
      services.cloudflared = {
        tunnels = {
          "b6ce003f-d222-4d1c-8e67-56ac678280ba" = {
            credentialsFile = "${config.sops.secrets.ark-rp-viz-cloudflare-creds.path}";
            default = "http_status:404";
            ingress = {
              ${myCfg.domain} = "http://127.0.0.1:${toString myCfg.port}";
            };
          };
        };
      };
      sops.secrets.ark-rp-viz-cloudflare-creds = {};
    };
  };
}
