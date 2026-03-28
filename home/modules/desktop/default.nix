{
  lib,
  desktop ? null,
  ...
}:

{
  imports =
    lib.optional (desktop == "kde") ./plasma-manager.nix
    ++ lib.optional (desktop == "hyprland") ./hyprland.nix;
}
