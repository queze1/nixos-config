{
  config,
  inputs,
  lib,
  options,
  ...
}: let
  cfg = config.my.desktop.noctalia;
in {
  options.my.desktop.noctalia.enable = lib.mkEnableOption "Noctalia";

  # Don't crash if programs.noctalia doesn't exist
  config = lib.optionalAttrs (options ? programs.noctalia) (lib.mkIf cfg.enable {
    programs.noctalia.enable = true;

    home-manager.sharedModules = [
      ({config, ...}: {
        programs.noctalia = {
          enable = true;
          settings = {
            accessibility.ui_scale = 1.1;
            shell = {
              font_family = "Liberation Mono";
              avatar_path = "${inputs.secrets}/assets/pfp.png";
              clipboard_enabled = false; # v5 default: true (overridden); v4: appLauncher.enableClipboardHistory
              clipboard_auto_paste = "off"; # v5 default: "auto" (overridden); v4: appLauncher.autoPasteClipboard
              session = {
                actions = [
                  {
                    action = "lock";
                    countdown_seconds = 0.0;
                    enabled = true;
                    shortcut = "1";
                    variant = "default";
                  }
                  {
                    action = "logout";
                    countdown_seconds = 0.0;
                    enabled = true;
                    shortcut = "2";
                    variant = "default";
                  }
                  {
                    action = "lock_and_suspend";
                    countdown_seconds = 0.0;
                    enabled = false;
                    shortcut = "3";
                    variant = "default";
                  }
                  {
                    action = "reboot";
                    countdown_seconds = 0.0;
                    enabled = true;
                    shortcut = "4";
                    variant = "default";
                  }
                  {
                    action = "shutdown";
                    countdown_seconds = 0.0;
                    enabled = true;
                    shortcut = "5";
                    variant = "destructive";
                  }
                ];
              };
              shadow = {
                direction = "down_right"; # v5 default: "down" (overridden); v4: general.shadowDirection
              };
              panel = {
                open_near_click_control_center = true; # v5 default: false (overridden); v4: controlCenter.position; closest placement mapping
                session_position = "center"; # v5 default: "auto" (overridden); v4: sessionMenu.position
                session_placement = "floating"; # v5 default: "attached" (overridden); v4: sessionMenu.position; centered v4 session panel becomes floating
              };
              launcher = {
                providers = {
                  session = {
                    global = true; # v5 default: false (overridden); v4: appLauncher.enableSessionSearch
                  };
                };
              };
              screen_time_enabled = true;
            };
            wallpaper = {
              default.path = "${inputs.secrets}/assets/laine-chinensy-temptation-v6.png";
              directory = "${config.xdg.userDirs.pictures}/Wallpapers";
              transition_on_startup = true;
              edge_smoothness = 0.05; # v5 default: 0.3 (overridden); v4: wallpaper.transitionEdgeSmoothness
            };
            theme = {
              mode = "light"; # v5 default: "dark" (overridden); v4: colorSchemes.darkMode
              source = "wallpaper"; # v5 default: "builtin" (overridden); v4: colorSchemes.useWallpaperColors
              wallpaper_scheme = "m3-rainbow"; # v5 default: "m3-content" (overridden); v4: colorSchemes.generationMethod
              templates = {
                enable_builtin_templates = false; # v5 default: true (overridden); v4: templates.enableUserTheming; disable automatic app theming
                enable_community_templates = false; # v5 default: true (overridden); v4: templates.enableUserTheming
              };
            };
            notification = {
              layer = "overlay"; # v5 default: "top" (overridden); v4: notifications.overlayLayer
            };
            lockscreen = {
              transition = []; # v5 default: ["fade", "wipe", "disc", "stripes", "zoom", "honeycomb"] (overridden); v4: general.lockScreenAnimations
              blur_intensity = 0; # v5 default: 0.5 (overridden); v4: general.lockScreenBlur
            };
            brightness = {
              enable_ddcutil = true; # v5 default: false (overridden); v4: brightness.enableDdcSupport
            };
            nightlight = {
              enabled = true; # v5 default: false (overridden); v4: nightLight.enabled
            };
            location = {
              auto_locate = true; # v5 default: false (overridden); v4: location.autoLocate
              address = "Sydney"; # v5 default: "" (overridden); v4: location.name; retained fallback; auto_locate takes precedence
            };
            idle = {
              behavior = {
                lock = {
                  timeout = 600;
                  enabled = true;
                };
                screen-off = {
                  timeout = 300;
                  enabled = true;
                };
              };
            };
            bar = {
              main = {
                background_opacity = 0.93; # v5 default: 1.0 (overridden); v4: bar.backgroundOpacity
                margin_ends = 4; # v5 default: 180 (overridden); v4: bar.marginHorizontal
                margin_edge = 4; # v5 default: 10 (overridden); v4: bar.marginVertical
                padding = 2; # v5 default: 14 (overridden); v4: bar.contentPadding; closest geometry mapping; v4 and v5 layout units differ
                font_scale = 1.05; # v5 default: 1.0 (overridden); v4: bar.fontScale
                scale = 1.05;
                capsule = true; # v5 default: false (overridden); v4: bar.showCapsule
                start = ["workspaces" "active_window" "media"]; # v5 default: ["launcher", "wallpaper", "workspaces"] (overridden); v4: bar.widgets.left
                end = ["notifications" "volume" "session"];
              };
            };
            widget = {
              workspaces = {
                font_weight = 700; # v5 default: "inherited" (overridden); v4: bar.widgets.left.0.fontWeight
              };
              active_window = {
                max_length = 145; # v5 default: 260 (overridden); v4: bar.widgets.left.1.maxWidth
                title_scroll = "on_hover"; # v5 default: "none" (overridden); v4: bar.widgets.left.1.scrollingMode
              };
              media = {
                max_length = 145; # v5 default: 220 (overridden); v4: bar.widgets.left.2.maxWidth
                title_scroll = "on_hover"; # v5 default: "none" (overridden); v4: bar.widgets.left.2.scrollingMode
                artist_first = true; # v5 default: false (overridden); v4: bar.widgets.left.2.showArtistFirst
                hide_when_no_media = true; # v5 default: false (overridden); v4: bar.widgets.left.2.hideMode; closest mapping for the empty media widget
              };
              clock = {
                format = "{:%H:%M %a, %d/%m/%Y}"; # v5 default: "{:%H:%M}" (overridden); v4: bar.widgets.center.0.formatHorizontal
                vertical_format = "{:%H %M - %d %m}"; # v5 default: "" (overridden); v4: bar.widgets.center.0.formatVertical
                tooltip_format = "{:%H:%M %a, %b %d}"; # v5 default: "" (overridden); v4: bar.widgets.center.0.tooltipFormat
              };
              volume = {
                show_label = false; # v5 default: true (overridden); v4: bar.widgets.right.2.displayMode; approximation: v5 lacks documented hover-only label mode
                actions = {
                  middle = "exec pwvucontrol || pavucontrol"; # v5 default: "open widget settings" (overridden); v4: bar.widgets.right.2.middleClickCommand
                };
              };
            };
          };
        };
      })
    ];
  });
}
