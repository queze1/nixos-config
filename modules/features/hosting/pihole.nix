{
  flake.nixosModules.pihole = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.pihole-ftl;
    myCfg = config.my.apps.pihole;

    piholeUrl = "https://${myCfg.domain}";
    piholePasswordFile = "/etc/pihole/cli_pw";
    piholeBackupDir = "${cfg.stateDirectory}/backups";
    piholeBackupScript = pkgs.writeShellApplication {
      name = "pihole-backup";
      runtimeInputs = [pkgs.curl pkgs.jq pkgs.coreutils];
      text = ''
        set -euo pipefail

        if [ ! -r "${piholePasswordFile}" ]; then
          echo "Cannot read password file: ${piholePasswordFile}" >&2
          exit 1
        fi

        PASSWORD=$(<"${piholePasswordFile}")
        RESPONSE=$(curl -sk -X POST "${piholeUrl}/api/auth" \
          --data "{\"password\":\"''${PASSWORD}\"}")
        SID=$(echo "$RESPONSE" | jq -r '.session.sid')

        if [ -z "''${SID}" ] || [ "''${SID}" = "null" ]; then
          echo "Auth failed, response was: ''${RESPONSE}" >&2
          exit 1
        fi

        mkdir -p "${piholeBackupDir}"
        TIMESTAMP=$(date +%Y%m%d-%H%M%S)
        OUTFILE="${piholeBackupDir}/''${TIMESTAMP}-backup.zip"

        curl -sk -X GET "${piholeUrl}/api/teleporter" \
          -H "accept: application/zip" \
          -H "sid: ''${SID}" \
          -o "''${OUTFILE}"

        # Invalidate the session now that we're done with it
        curl -sk -X DELETE "${piholeUrl}/api/auth" \
          -H "sid: ''${SID}" >/dev/null || true

        echo "Backup written to ''${OUTFILE}"
      '';
    };
  in {
    options.my.apps.pihole = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "pi-hole.osipol.uk";
        description = "Domain to host the Pi-Hole web server on.";
      };
      ports = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Port(s) for the Pi-Hole webserver to serve on.";
      };
    };
    config = {
      services.pihole-ftl = {
        enable = true;
        settings = {
          dns = {
            upstreams = [
              # Cloudflare DNS
              "1.1.1.1"
              "1.0.0.1"
              # 2606:4700:4700::1111"
              "2606:4700:4700::1001"
            ];
            listeningMode = "SINGLE";
            interface = config.services.tailscale.interfaceName;
          };
        };
        # Has bug where setup service will try to add a list even if it already exists, causing an error
        # lists = [
        #   {
        #     url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
        #   }
        # ];
      };

      services.pihole-web = {
        enable = true;
        ports = myCfg.ports;
      };

      # Configure secrets
      systemd.services.pihole-ftl = {
        serviceConfig.EnvironmentFile = config.sops.secrets.pihole-env.path;
      };
      sops.secrets.pihole-env = {
        restartUnits = ["pihole-ftl.service"];
      };

      # Preserve PiHole state
      my.preservation.extraDirectories = [
        {
          directory = cfg.stateDirectory;
          user = cfg.user;
          group = cfg.group;
          mode = "0700";
        }
      ];

      systemd.services.pihole-backup = {
        description = "Back up Pi-hole config";
        after = ["pihole-ftl.service"];
        wants = ["pihole-ftl.service"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${piholeBackupScript}/bin/pihole-backup";
          # Simulate the requests coming through Caddy
          User = config.services.caddy.user;
        };
      };

      systemd.timers.pihole-backup = {
        description = "Daily Pi-hole backup";
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };

      # Back up Pihole data & daily backup dumps
      my.restic.extraPaths = [cfg.stateDirectory];

      # Open firewall for DNS server on Tailscale only
      networking.firewall.interfaces.${config.services.tailscale.interfaceName} = {
        allowedUDPPorts = [53];
        allowedTCPPorts = [53];
      };

      # Reverse proxy with Tailscale auth
      services.caddy.virtualHosts = {
        ${myCfg.domain} = {
          extraConfig = ''
            import cloudflare_dns
            @protected not path /api/info/client
            import tailscale_auth @protected
            reverse_proxy localhost:${toString myCfg.ports}
          '';
        };
      };
      services.ddclient.domains = [myCfg.domain];

      # Only allow Caddy to access this port
      my.caddy.firewalledPorts = map lib.toIntBase10 myCfg.ports;
    };
  };
}
