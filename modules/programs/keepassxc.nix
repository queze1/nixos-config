{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.keepassxc;
in {
  options.my.programs.keepassxc.enable = lib.mkEnableOption "KeePassXC" // {default = config.my.programs.enableAll;};

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.keepassxc];

        my.home.preservation.extraDirectories = [
          ".cache/keepassxc"
          ".config/keepassxc"
        ];
      })
    ];
  };
}
