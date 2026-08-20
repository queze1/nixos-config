{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.fonts;
in {
  options.my.fonts.enable = lib.mkEnableOption "fonts";

  config = lib.mkIf cfg.enable {
    fonts = {
      enableDefaultPackages = true;

      packages = with pkgs; [
        corefonts
        nerd-fonts.fira-code
        nerd-fonts.droid-sans-mono
      ];

      fontconfig = {
        enable = true;
        hinting = {
          enable = false;
        };
      };
    };
  };
}
