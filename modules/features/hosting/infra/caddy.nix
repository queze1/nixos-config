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
        openFirewall = true; # open ports 80 and 443
        package = pkgs.caddy.withPlugins {
          plugins = [
            "github.com/caddy-dns/cloudflare@v0.2.4"
          ];
          hash = "sha256-7GoH8YLCoPmPExQxoga2FHB58zQDoZVf1BBwkVi0SsQ=";
        };

        extraConfig = ''
          admin unix//run/caddy-admin.sock

          (cloudflare_dns) {
            tls {
            	dns cloudflare {file.${config.sops.secrets.osipol-cloudflare-api-token.path}}
              propagation_timeout -1
              propagation_delay 15s
            }
          }

          (tailscale_auth) {
            forward_auth unix//${config.services.tailscaleAuth.socketPath} {
              uri /auth
              header_up Remote-Addr {remote_host}
              header_up Remote-Port {remote_port}
              header_up Original-URI {uri}
              copy_headers {
                Tailscale-User>X-Webauth-User
                Tailscale-Name>X-Webauth-Name
                Tailscale-Login>X-Webauth-Login
                Tailscale-Tailnet>X-Webauth-Tailnet
                Tailscale-Profile-Picture>X-Webauth-Profile-Picture
              }
            }
          }
        '';
      };

      sops.secrets.osipol-cloudflare-api-token = {
        owner = config.services.caddy.user;
        group = config.services.caddy.group;
      };

      # Preserve Caddy data
      my.preservation.extraDirectories = [
        {
          directory = config.services.caddy.dataDir;
          user = config.services.caddy.user;
          group = config.services.caddy.group;
          mode = "0700";
        }
      ];

      networking.nftables.tables."caddy-firewall" = lib.optional (myCfg.firewalledPorts == []) {
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
}
