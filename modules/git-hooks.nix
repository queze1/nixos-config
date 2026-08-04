{inputs, ...}: {
  imports = [
    inputs.git-hooks-nix.flakeModule
  ];

  perSystem = {config, ...}: {
    devShells.default = config.pre-commit.devShell;

    pre-commit.settings.hooks = {
      alejandra.enable = true;
      commitizen.enable = true;
      deadnix.enable = true;
      flake-checker.enable = true;
    };
  };
}
