# CURRENTLY UNUSED, use if you want a NAS and not just Restic backup
{
  flake.nixosModules.garage = {
    config,
    lib,
    pkgs,
    ...
  }: let
    apiPort = 3900;
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
          api_bind_addr = "[::]:${toString apiPort}";
          root_domain = ".garage-s3.osipol.uk";
        };

        admin = {
          api_bind_addr = "[::]:3903";
        };
      };
    };

    sops.secrets.garage-env = {
      restartUnits = ["garage.service"];
    };

    # Create a system user to run Garage
    users.users.garage = {
      isSystemUser = true;
      group = "garage";
    };
    users.groups.garage = {};

    # Override systemd to use a static user
    systemd.services.garage.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "garage";
      Group = "garage";
    };

    # Preserve Garage data
    my.preservation.extraDirectories = [
      {
        directory = "/var/lib/garage";
        user = "garage";
        group = "garage";
        mode = "700";
      }
    ];

    # Networking with Cloudflare tunnel
    services.cloudflared = {
      enable = true;
      tunnels = {
        "9d3af70e-bb75-4731-a99c-145865a1bb5f" = {
          credentialsFile = "${config.sops.secrets.garage-cloudflare-creds.path}";
          default = "http_status:404";
          ingress = {
            "garage-s3.osipol.uk" = "http://127.0.0.1:${toString apiPort}";
          };
        };
      };
    };
    sops.secrets.garage-cloudflare-creds = {};
  };
}
