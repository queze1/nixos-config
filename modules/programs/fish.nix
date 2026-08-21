{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.fish;
in {
  options.my.programs.fish.enable = lib.mkEnableOption "Fish" // {default = config.my.programs.enableAll;};

  config = lib.mkIf cfg.enable {
    programs.fish.enable = true;
    home-manager.sharedModules = [
      {
        # Preserve fish command history
        my.home.preservation.extraDirectories = [
          ".local/share/fish"
        ];

        programs.fish = {
          enable = true;
        };
      }
    ];
  };
}
