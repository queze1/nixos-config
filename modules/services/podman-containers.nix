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
  };
}
