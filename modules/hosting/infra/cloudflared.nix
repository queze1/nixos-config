{
  config,
  lib,
  ...
}: {
  options.my.cloudflared.enable = lib.mkEnableOption "Cloudflared";

  config = lib.mkIf config.my.cloudflared.enable {
    services.cloudflared.enable = true;

    # Hardening
    systemd.services =
      lib.mapAttrs' (
        name: _:
          lib.nameValuePair "cloudflared-tunnel-${name}" {
            serviceConfig = {
              NoNewPrivileges = true;
              PrivateDevices = true;
              PrivateTmp = true;
              ProtectClock = true;
              ProtectControlGroups = true;
              ProtectHome = true;
              ProtectHostname = true;
              ProtectKernelLogs = true;
              ProtectKernelModules = true;
              ProtectKernelTunables = true;
              ProtectSystem = "strict";
              RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK"];
              RestrictNamespaces = true;
              RestrictRealtime = true;
              RestrictSUIDSGID = true;
              LockPersonality = true;
              SystemCallArchitectures = "native";
              SystemCallFilter = ["@system-service" "~@privileged @resources"];
              UMask = "0077";
            };
          }
      )
      config.services.cloudflared.tunnels;
  };
}
