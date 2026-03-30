{
  pkgs,
  ...
}:

{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # ---- KDE Plasma ----
  services.desktopManager.plasma6.enable = true;

  # ---- Hyprland ----
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  environment.systemPackages = with pkgs; [
    kitty
  ];
}
