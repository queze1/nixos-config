{
  flake.nixosModules.podman = {
    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
      };
    };

    virtualisation.oci-containers.backend = "podman";
  };
}
