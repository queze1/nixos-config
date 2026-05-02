{
  pkgs,
  desktop,
  ...
}:
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.gnome.gnome-keyring.enable = true;

  # environment.sessionVariables = {
  #   NIXOS_OZONE_WL = "1";
  # };

  xdg.portal = {
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
    ];
    config.niri = {
      "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
    };
  };

  services.desktopManager.plasma6.enable = desktop.plasma;
  programs.niri.enable = desktop.niri;
}
