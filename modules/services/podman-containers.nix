{
  config,
  lib,
  ...
}: let
  cfg = config.my.podmanContainers;
in {
  options.my.podmanContainers.enable = lib.mkEnableOption "Podman containers";

  config = lib.mkIf cfg.enable {
    virtualisation = {
      containers.enable = true;
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        dockerCompat = true;
      };
    };

    # Preserve container storage
    # Consider disabling this and seeing what happens
    my.preservation.extraDirectories = [
      {
        directory = "/var/lib/containers";
        user = "root";
        group = "root";
        mode = "0700";
      }
    ];
  };
}
