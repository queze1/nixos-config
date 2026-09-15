{lib, ...}: {
  options.flake = {
    factory = lib.mkOption {
      type = lib.types.attrsOf lib.types.raw;
      default = {};
    };

    # Since there is no flake-parts module for nix-darwin, specify custom options
    darwinConfigurations = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
    };

    darwinModules = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = {};
    };
  };
}
