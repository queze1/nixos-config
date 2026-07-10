{
  flake.nixosModules.podman = {
    virtualisation = {
      containers.enable = true;
      podman = {
        enable = true;
        dockerCompat = true;
      };
    };
  };
}
