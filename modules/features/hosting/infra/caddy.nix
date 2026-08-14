{
  flake.nixosModules.caddy = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.services.caddy;
    myCfg = config.my.caddy;

    uid = config.users.users.${cfg.user}.uid;
    firewalledPortsStr = lib.join "," (lib.map toString myCfg.firewalledPorts);
  in {
    options.my.caddy.firewalledPorts = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [];
      example = [8000 8001];
      description = "Ports to prevent any user from accessing other than Caddy.";
    };

    config = {
      services.caddy = {
        enable = true;
        package = pkgs.caddy.withPlugins {
          plugins = [
            "github.com/caddy-dns/cloudflare@v0.2.4"
          ];
          hash = "sha256-7GoH8YLCoPmPExQxoga2FHB58zQDoZVf1BBwkVi0SsQ=";
        };

        globalConfig = ''
          admin unix//run/caddy/caddy-admin.sock
        '';
        extraConfig = ''
          (cloudflare_dns) {
            tls {
              dns cloudflare {file.${config.sops.secrets.osipol-cloudflare-api-token.path}}
              propagation_timeout -1
              propagation_delay 15s
            }
          }
        '';
      };

      # Initialise a directory to put the socket
      systemd.services.caddy.serviceConfig = {
        RuntimeDirectory = "caddy";
        RuntimeDirectoryMode = "0700";
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

      # For Cloudflare DNS
      sops.secrets.osipol-cloudflare-api-token = {
        owner = cfg.user;
        group = cfg.group;
      };

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
    };
  };
}
