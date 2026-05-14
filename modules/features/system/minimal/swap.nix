{
  flake.nixosModules.minimalSystem = {
    zramSwap.enable = true;
  };
}
