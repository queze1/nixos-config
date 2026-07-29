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

        s3_web = {
          bind_addr = "[::]:3902";
          root_domain = ".web.garage.localhost";
          index = "index.html";
        };

        admin = {
          api_bind_addr = "[::]:3903";
        };
      };
    };

    sops.secrets.garage-env = {
      restartUnits = ["garage.service"];
    };

    my.preservation.extraDirectories = [
      cfg.settings.data_dir
      cfg.settings.metadata_dir
    ];
  };
}
