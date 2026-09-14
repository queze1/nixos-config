{...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      shellHook = ''
        ${config.pre-commit.shellHook}
      '';

      packages = config.pre-commit.settings.enabledPackages;
    };

    pre-commit.settings.hooks = {
      alejandra.enable = true;
      commitizen.enable = true;
      deadnix.enable = true;
      flake-checker.enable = true;
    };
  };
}
