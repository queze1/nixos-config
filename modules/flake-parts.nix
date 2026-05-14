{ inputs, ... }:
{
  config = {
    # Import home-manager's flake module
    imports = [
      inputs.home-manager.flakeModules.home-manager
    ];

    systems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
