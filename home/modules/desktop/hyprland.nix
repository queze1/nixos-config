{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false; # Fix conflict with uswm
  };

  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bind = [
      "$mod, Q, exec, kitty" # Open terminal
      "$mod, C, killactive," # Close the active window
      "$mod, M, exit," # Force quit Hyprland
      "$mod, V, togglefloating," # Make a window float
      "$mod, R, exec, wofi --show drun" # App launcher
      "$mod, P, pseudo," # dwindle (tiling layout)
      "$mod, J, togglesplit," # dwindle (tiling layout)
      "$mod, F, exec, uwsm app -- firefox"
    ]
    ++ (
      # workspaces
      # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
      builtins.concatLists (
        builtins.genList (
          i:
          let
            ws = i + 1;
          in
          [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
          ]
        ) 9
      )
    );
    exec-once = [
      "uwsm app -- waybar"
      "uwsm app -- hyprpaper"
      "uwsm app -- mako"
    ];
  };

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Sans";
      size = 11;
    };
  };

  # Hyprland-specific tools
  home.packages = with pkgs; [
    waybar # status bar
    wofi # app launcher
    hyprpaper # wallpaper
    grimblast # screenshots
  ];
}
