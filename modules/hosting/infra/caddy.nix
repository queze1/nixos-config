{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.caddy;
  myCfg = config.my.caddy;

  uid = config.users.users.${cfg.user}.uid;
  firewalledPortsStr = lib.join "," (lib.map toString myCfg.firewalledPorts);
in {
  options.my.caddy = {
    enable = lib.mkEnableOption "Caddy";
    cloudflareDns.enable = lib.mkEnableOption "Cloudflare DNS for Caddy";
    firewalledPorts = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [];
      example = [8000 8001];
      description = "Ports to prevent any user from accessing other than Caddy.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf myCfg.enable {
      services.caddy = {
        enable = true;
        globalConfig = ''
          admin unix//run/caddy/caddy-admin.sock
        '';
      };

      systemd.services.caddy.serviceConfig = {
        # Initialise a directory to put the socket
        RuntimeDirectory = "caddy";
        RuntimeDirectoryMode = "0700";

        # Hardening
        ProtectSystem = "strict";
        PrivateTmp = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        RemoveIPC = true;
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK"];
        SystemCallFilter = ["@system-service" "~@privileged @resources"];
        SystemCallArchitectures = "native";
        UMask = "0077";
      };

      # Preserve Caddy data
      my.preservation.extraDirectories = [
        {
          directory = cfg.dataDir;
          user = cfg.user;
          group = cfg.group;
          mode = "0700";
        }
      ];

      # Back up Caddy data
      my.restic.extraPaths = ["${cfg.dataDir}/.local/share/caddy"];

      # Open ports on Tailscale
      networking.firewall.interfaces.${config.services.tailscale.interfaceName} = {
        allowedTCPPorts = [
          cfg.httpPort
          cfg.httpsPort
        ];
        allowedUDPPorts = [cfg.httpsPort];
      };

      # Allow Caddy to fetch Tailscale TLS certificates
      services.tailscale.permitCertUid = cfg.user;

      # Firewall services which are meant to route through Caddy
      networking.nftables.tables = lib.mkIf (myCfg.firewalledPorts != []) {
        "caddy-firewall" = {
          family = "inet";
          content = ''
            chain output {
              type filter hook output priority filter; policy accept;

              oif "lo" tcp dport {${firewalledPortsStr}} meta skuid ${toString uid} accept
              oif "lo" tcp dport {${firewalledPortsStr}} drop
            }
          '';
        };
      };
    })
    (lib.mkIf myCfg.cloudflareDns.enable {
      services.caddy = {
        package = pkgs.caddy.withPlugins {
          plugins = [
            "github.com/caddy-dns/cloudflare@v0.2.4"
          ];
          hash = "sha256-7GoH8YLCoPmPExQxoga2FHB58zQDoZVf1BBwkVi0SsQ=";
        };
        extraConfig = ''
          (cloudflare_dns) {
            tls {
              dns cloudflare {file.${config.sops.secrets.cloudflare-api-token.path}}
              propagation_timeout -1
              propagation_delay 15s
            }
          }
        '';
      };

      sops.secrets.cloudflare-api-token = {
        owner = cfg.user;
        group = cfg.group;
      };
    })
  ];
}
