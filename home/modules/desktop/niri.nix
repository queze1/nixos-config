{
  pkgs,
  ...
}:

{
  xdg.configFile."niri/config.kdl".source = ./niri-config.kdl;
  home.packages = with pkgs; [
    xwayland-satellite # xwayland support
  ];
}
