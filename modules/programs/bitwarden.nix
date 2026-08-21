{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.bitwarden;
in {
  options.my.programs.bitwarden.enable = lib.mkEnableOption "Bitwarden" // {default = config.my.programs.enableAll;};

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = with pkgs; [
          bitwarden-desktop
          bitwarden-cli
        ];

        my.home.preservation.extraDirectories = [
          ".config/Bitwarden"
          ".config/Bitwarden CLI"
        ];
      })
    ];
  };
}
