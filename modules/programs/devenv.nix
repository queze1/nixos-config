{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.devenv;
in {
  options.my.programs.devenv.enable = lib.mkEnableOption "devenv" // {default = config.my.programs.enableAll;};

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.devenv];

        # Preserve devenv allow
        my.home.preservation.extraDirectories = [
          ".local/share/devenv"
        ];

        # Automatically enter devenv shell with Fish
        programs.fish.interactiveShellInit = ''
          devenv hook fish | source
        '';
      })
    ];
  };
}
