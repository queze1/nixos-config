{inputs, ...}: {
  imports = [
    inputs.home-manager.flakeModules.home-manager
    inputs.git-hooks-nix.flakeModule
  ];

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
  };
}
