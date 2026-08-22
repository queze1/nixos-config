{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.home-manager.flakeModules.home-manager
    inputs.git-hooks-nix.flakeModule
  ];

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

  config = {
    # For nixd hints
    debug = true;

    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    flake.templates.default = {
      path = ../templates/flake;
      description = "A basic flake template";
    };

    perSystem = {config, ...}: {
      devShells.default = config.pre-commit.devShell;

      pre-commit.settings.hooks = {
        alejandra = {
          enable = true;
          settings.exclude = ["npins/default.nix"];
        };
        commitizen.enable = true;
        deadnix.enable = true;
        flake-checker.enable = true;
      };
    };
  };
}
