{
  desktop,
  ...
}:
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  services.desktopManager.plasma6.enable = desktop.plasma;
  programs.niri.enable = desktop.niri;
}
