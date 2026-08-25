{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  myCfg = config.my.apps.filebrowser-quantum;
  package = self.packages.${pkgs.stdenv.hostPlatform.system}.filebrowser-quantum;

  dataDir = "/var/lib/filebrowser-quantum";
  defaultSource = "${dataDir}/files";
  user = myCfg.user;
  configFile = (pkgs.formats.yaml {}).generate "filebrowser-quantum.yaml" {
    server = {
      database.path = "${dataDir}/filebrowser.sqlite";
      cacheDir = "${dataDir}/cache";
      sources =
        map (path: {
          inherit path;
          config.defaultEnabled = true;
        })
        (lib.optional myCfg.useDefaultSource defaultSource ++ myCfg.sources);
    };
    http = {
      port = myCfg.port;
      listen = "127.0.0.1";
      externalUrl = "https://${myCfg.domain}";
      trustProxyHeaders = true;
    };
    # userDefaults.account.permissions.admin = true; # uncomment for first use
    auth = {
      adminUsername = "admin";
      methods.proxy = {
        enabled = true;
        header = "X-Webauth-User";
      };
    };
  };
in {
  options.my.apps.filebrowser-quantum = {
    enable = lib.mkEnableOption "FileBrowser Quantum";
    user = lib.mkOption {
      type = lib.types.str;
      default = "filebrowser-quantum";
      description = "User running FileBrowser Quantum.";
    };
    sources = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Directories exposed by FileBrowser Quantum.";
    };
    useDefaultSource = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to expose FileBrowser Quantum's data directory.";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "filebrowser.osipol.uk";
      description = "Domain to host FileBrowser Quantum on.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8008;
      description = "Port to run FileBrowser Quantum on.";
    };
  };

  config = lib.mkIf myCfg.enable {
    systemd.services.filebrowser-quantum = {
      description = "FileBrowser Quantum";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      preStart = lib.optionalString myCfg.useDefaultSource ''
        mkdir -p ${defaultSource}
      '';
      serviceConfig = {
        ExecStart = "${lib.getExe package} -c ${configFile}";
        User = user;
        Group = user;
        EnvironmentFile = config.sops.secrets.filebrowser-quantum-env.path;
        Restart = "on-failure";

        WorkingDirectory = dataDir;
        ReadWritePaths = myCfg.sources;
        StateDirectory = "filebrowser-quantum";
        StateDirectoryMode = "0700";

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

    # Create a system user for FileBrowser
    users.users.${user} = {
      isSystemUser = true;
      group = user;
      home = dataDir;
    };
    users.groups.${user} = {};

    sops.secrets.filebrowser-quantum-env = {
      owner = user;
      group = user;
      restartUnits = ["filebrowser-quantum.service"];
    };

    # Preserve FileBrowser data
    my.preservation.extraDirectories = [
      {
        directory = dataDir;
        user = user;
        group = user;
        mode = "0700";
      }
    ];

    # Backup FileBrowser data
    my.restic.extraPaths = [dataDir];

    # Reverse proxy with Tailscale auth
    services.caddy.virtualHosts.${myCfg.domain}.extraConfig = ''
      import cloudflare_dns
      @protected not path /public/* /health
      import tailscale_auth @protected
      reverse_proxy 127.0.0.1:${toString myCfg.port}
    '';
    services.ddclient.domains = [myCfg.domain];

    # Only allow Caddy to access this port
    my.caddy.firewalledPorts = [myCfg.port];
  };
}
