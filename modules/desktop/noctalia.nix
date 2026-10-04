{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.my.desktop.noctalia;
in {
  options.my.desktop.noctalia.enable = lib.mkEnableOption "Noctalia";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({config, ...}: {
        imports = [inputs.noctalia.homeModules.default];

        programs.noctalia = {
          enable = true;
          settings = {
            accessibility.ui_scale = 1.1;
            shell = {
              avatar_path = "${inputs.secrets}/assets/pfp.png";
              font_family = "Liberation Mono";
              panel = {
                borders = true;
                control_center_placement = "attached";
                transparency_mode = "glass";
                wallpaper_placement = "attached";
              };
              shadow = {
                direction = "down_right";
              };
            };
            wallpaper = {
              default.path = "${inputs.secrets}/assets/laine-chinensy-temptation-v6.png";
              directory = "${config.xdg.userDirs.pictures}/Wallpapers";
              fill_mode = "crop";
            };
            theme = {
              mode = "light";
              source = "wallpaper";
              wallpaper_scheme = "m3-rainbow";
            };
            weather = {
              effects = true;
              enabled = true;
              unit = "metric";
            };
            location.address = "Sydney, Australia";
            nightlight = {
              enabled = true;
              temperature_day = 6500;
              temperature_night = 4000;
            };
            lockscreen = {
              enabled = true;
              lock_before_suspend = true;
            };
            idle.behavior = {
              lock = {
                action = "lock";
                enabled = true;
                timeout = 660;
              };
              screen-off = {
                action = "screen_off";
                enabled = true;
                timeout = 300;
              };
            };
            bar.default = {
              background_opacity = 0.93;
              capsule = true;
              capsule_opacity = 1.0;
              font_scale = 1.05;
              margin_edge = 4;
              margin_ends = 4;
              position = "top";
              start = ["workspaces" "active_window" "media"];
              center = ["clock"];
              end = ["tray" "notifications" "volume" "theme_mode"];
              widget_spacing = 6;
            };
            widget.workspaces = {
              labels_only_when_occupied = true;
              show_labels = true;
            };
          };
        };
      })
    ];
  };
}
