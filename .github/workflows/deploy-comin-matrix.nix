configs: let
  runnerForSystem = {
    "x86_64-linux" = "ubuntu-latest";
    "aarch64-linux" = "ubuntu-26.04-arm";
  };
  # Filter for configs with comin enabled
  names = builtins.filter (name: configs.${name}.config.services.comin.enable) (builtins.attrValues configs);
in
  map (
    name: let
      config = configs.${name};
      system = config.pkgs.stdenv.hostPlatform.system;
    in {
      attr = ".#nixosConfigurations.${name}.config.system.build.toplevel";
      runner = runnerForSystem.${system};
    }
  )
  names
