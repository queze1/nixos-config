{
  config,
  lib,
  ...
}: let
  cfg = config.my.desktop;
in {
  options.my.desktop.enable = lib.mkEnableOption "desktop environment";

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
}
