# Not worth unless you can set up a cluster of 3
{
  flake.nixosModules.garage = {
    config,
    lib,
    pkgs,
    ...
  }: let
    myCfg = config.my.garage;
  in {
    options.my.garage = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "garage.osipol.uk";
        description = "Domain to host Garage on.";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/garage";
        description = "Path where Garage stores its data.";
      };
      apiSocketPath = lib.mkOption {
        type = lib.types.str;
        default = "/run/garage/s3_api.sock";
        description = "Socket where Garage serves its S3 API.";
      };
      adminSocketPath = lib.mkOption {
        type = lib.types.str;
        default = "/run/garage/admin.sock";
        description = "Socket where Garage serves its S3 API.";
      };
    };

    config = {
      services.garage = {
        enable = true;
        package = pkgs.garage_2;
        environmentFile = config.sops.secrets.garage-env.path;
        settings = {
          metadata_dir = "${myCfg.dataDir}/meta";
          data_dir = "${myCfg.dataDir}/data";

          db_engine = "sqlite";
          replication_factor = 1;

          rpc_bind_addr = "127.0.0.1:3901";
          rpc_public_addr = "127.0.0.1:3901";

          s3_api = {
            s3_region = "garage";
            api_bind_addr = myCfg.apiSocketPath;
            root_domain = ".${myCfg.domain}";
          };

          admin = {
            api_bind_addr = myCfg.adminSocketPath;
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

      systemd.services.garage = {
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "garage";
          Group = "garage";
          RuntimeDirectory = "garage";
        };
      };

      # Give Caddy access to sockets
      users.users.${config.services.caddy.user}.extraGroups = ["garage"];

      # Preserve Garage data
      my.preservation.extraDirectories = [
        {
          directory = myCfg.dataDir;
          user = "garage";
          group = "garage";
          mode = "700";
        }
      ];

      # Reverse proxy
      services.caddy.virtualHosts = {
        "s3.${myCfg.domain}, *.s3.${myCfg.domain}".extraConfig = ''
          import cloudflare_dns
          reverse_proxy unix/${myCfg.apiSocketPath}
        '';
        "admin.${myCfg.domain}".extraConfig = ''
          import cloudflare_dns
          reverse_proxy unix/${myCfg.adminSocketPath}
        '';
      };
      services.ddclient.domains = ["*.${myCfg.domain}"];
    };
  };
}
