{
  flake.nixosModules.restic = {
    services.restic = {
      enable = true;
    };
  };
}
