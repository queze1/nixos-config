{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  myCfg = config.my.apps.ark-rp-viz;
  ark-rp-visualisation = inputs.ark-rp-visualisation.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  options.my.apps.ark-rp-viz = {
    enable = lib.mkEnableOption "ARK RP Visualisation";
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

  config = lib.mkIf myCfg.enable {
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
        ExecStart = lib.getExe ark-rp-visualisation;
        User = "ark-rp-viz";
        Group = "ark-rp-viz";
        Restart = "always";

        Environment = ''
          PORT=${toString myCfg.port}
        '';
        EnvironmentFile = config.sops.secrets.ark-rp-visualisation-env.path;
        StateDirectory = "ark-rp-viz";

        # Hardening
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateBPF = true;
        PrivateDevices = true;
        PrivateIPC = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "noaccess";
        ProcSubset = "pid";
        ProtectSystem = "strict";
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = ["@system-service" "~memfd_create"];
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
}
