{
  flake.nixosModules.garage = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.services.garage;
  in {
    services.garage = {
      enable = true;
      package = pkgs.garage_2;
      environmentFile = config.sops.secrets.garage-env.path;
      settings = {
        metadata_dir = "/var/lib/garage/meta";
        data_dir = "/var/lib/garage/data";

        db_engine = "sqlite";
        replication_factor = 1;

        rpc_bind_addr = "[::]:3901";
        rpc_public_addr = "127.0.0.1:3901";

        s3_api = {
          s3_region = "garage";
          api_bind_addr = "[::]:3900";
          root_domain = ".s3.garage.localhost";
        };

        admin = {
          api_bind_addr = "[::]:3903";
        };
      };
    };

    sops.secrets.garage-env = {
      restartUnits = ["garage.service"];
    };

    # Preserve Garage data
    my.preservation.extraDirectories = [
      "/var/lib/garage"
    ];

    # Networking with Cloudflare tunnel
    services.caddy.virtualHosts."http://garage-s3.osipol.uk" = {
      extraConfig = ''
        bind 127.0.0.1 ::1
        reverse_proxy ${toString cfg.settings.s3_api.api_bind_addr}
      '';
    };
    services.cloudflared.tunnels."b6ce003f-d222-4d1c-8e67-56ac678280ba".ingress = {
      "garage-s3.osipol.uk" = "http://localhost:80";
    };
  };
}
