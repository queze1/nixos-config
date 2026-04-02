{
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

  # ---- KDE Plasma ----
  services.desktopManager.plasma6.enable = true;

  # ---- Niri ----
  programs.niri.enable = true;
}
