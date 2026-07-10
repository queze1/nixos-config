{
  flake.nixosModules.yubal = {
    virtualisation.oci-containers = {
      backend = "podman";
      containers.yubal = {
        image = "ghcr.io/guillevc/yubal:latest";
        autoStart = true;
        ports = ["8000:8000"];

        environment = {
          PUID = "1000";
          PGID = "1000";
          YUBAL_SCHEDULER_CRON = "0 0 * * *"; # every midnight
          YUBAL_DOWNLOAD_UGC = "false";
          YUBAL_TZ = "UTC";
        };

        volumes = [
          "/var/lib/yubal/data:/app/data"
          "/var/lib/yubal/config:/app/config"
        ];
      };
    };
  };
}
