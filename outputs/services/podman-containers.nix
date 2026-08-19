{
  flake.nixosModules.podmanContainers = {
    virtualisation = {
      containers.enable = true;
      oci-containers.backend = "podman";
      podman = {
        enable = true;
        dockerCompat = true;
      };
    };

    # Preserve container storage so images aren't stored in RAM
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
