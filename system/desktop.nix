{
  lib,
  pkgs,
  desktop,
  neovim-config,
  ...
}:

{
  config = lib.mkMerge [
    {
      # Ugly, move elsewhere later
      nixpkgs.overlays = [
        neovim-config.overlays.default
      ];

      environment.systemPackages = with pkgs; [
        nvim-pkg
      ];
    }

    # ---- KDE Plasma Config ----
    (lib.mkIf (desktop == "kde") {
      services.xserver.enable = true;
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;
    })

    # ---- GNOME Config ----
    (lib.mkIf (desktop == "gnome") {
      services.xserver.enable = true;
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;
    })

    # ---- Hyprland Config ----
    (lib.mkIf (desktop == "hyprland") {
      programs.hyprland.enable = true;
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        settings = {
          Theme = {
            CursorTheme = "Bibata-Modern-Classic";
            CursorSize = 16;
          };
        };
      };

      environment.systemPackages = with pkgs; [
        kitty
      ];

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
      };
    })
  ];
}
