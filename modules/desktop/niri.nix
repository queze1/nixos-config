{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.desktop.niri;
  isUtm = config.my.utm.enable;
  usingExternalMonitor = false;
in {
  options.my.desktop.niri.enable = lib.mkEnableOption "niri";

  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };

    home-manager.sharedModules = [
      ({config, ...}: let
        bind = action: args: {
          ${action} =
            if args == []
            then {}
            else args;
        };
        noArgs = action: keys: lib.genAttrs keys (_: bind action []);
        noArgsWithProps = action: keys: props: lib.genAttrs keys (_: (bind action []) // {_props = props;});

        # Detect default applications for keybind descriptions
        defaultTerminal = let
          cfg = config.xdg.terminal-exec;
          defaults = cfg.settings.default or [];
        in
          if cfg.enable && defaults != []
          then lib.removeSuffix ".desktop" (lib.head defaults)
          else null;
        defaultBrowser = let
          defaults = config.xdg.mimeApps.defaultApplications."x-scheme-handler/https";
        in
          if defaults != []
          then lib.removeSuffix ".desktop" (lib.head defaults)
          else null;
      in {
        wayland.windowManager.niri = {
          enable = true;

          settings = {
            input = {
              keyboard.numlock = {};
              touchpad = {
                tap = {};
                natural-scroll = {};
              };
              workspace-auto-back-and-forth = {};
              focus-follows-mouse._props = {
                max-scroll-amount = "10%";
              };
            };

            layout = {
              gaps = 12;
              center-focused-column = "never";
              preset-column-widths._children = [
                {proportion = 0.5;}
                {proportion = 0.33333;}
                {proportion = 0.66667;}
              ];
              preset-window-heights._children = [
                {proportion = 0.5;}
                {proportion = 0.33333;}
                {proportion = 0.66667;}
                {proportion = 1.0;}
              ];
              default-column-width.proportion = 0.5;
              focus-ring = {
                off = {};
                width = 4;
                active-color = "#7fc8ff";
                inactive-color = "#505050";
              };
              border = {
                on = {};
                width = 3;
                active-color = "#7fc8ff";
                inactive-color = "#505050";
                urgent-color = "#9b0000";
              };
              shadow = {
                on = {};
                softness = 30;
                spread = 5;
                offset._props = {
                  x = 0;
                  y = 5;
                };
                color = "#0007";
              };
            };

            prefer-no-csd = {};
            screenshot-path = "${config.xdg.userDirs.pictures}/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

            _children = [
              {
                output = {
                  _args = ["Virtual-1"];
                  mode = {
                    _args = [
                      (
                        if usingExternalMonitor
                        then "1920x1080@60"
                        else "2560x1664@60"
                      )
                    ];
                    _props.custom = !usingExternalMonitor;
                  };
                  scale =
                    if usingExternalMonitor
                    then 1.125
                    else 2.0;
                };
              }
              {
                window-rule = {
                  match._props = {
                    app-id = "firefox$";
                    title = "^Picture-in-Picture$";
                  };
                  open-floating = true;
                };
              }
              {
                window-rule = {
                  match._props = {
                    app-id = "foot";
                    title = "^Yazi:.*";
                  };
                  default-column-width.proportion = 1.0;
                };
              }
              {
                window-rule = {
                  match._props.app-id = "imv";
                  default-column-width.proportion = 1.0;
                };
              }
            ];

            binds = lib.mkMerge [
              (noArgs "show-hotkey-overlay" ["Mod+Shift+Slash"])
              (noArgsWithProps "toggle-overview" ["Mod+O"] {repeat = false;})
              (noArgsWithProps "close-window" ["Mod+Q"] {repeat = false;})
              (noArgs "focus-column-left" ["Mod+Left" "Mod+H"])
              (noArgs "focus-column-right" ["Mod+Right" "Mod+L"])
              (noArgs "focus-window-down" ["Mod+Down"])
              (noArgs "focus-window-up" ["Mod+Up"])
              (noArgs "focus-window-or-workspace-down" ["Mod+J"])
              (noArgs "focus-window-or-workspace-up" ["Mod+K"])
              (noArgs "move-column-left" ["Mod+Ctrl+Left" "Mod+Ctrl+H"])
              (noArgs "move-column-right" ["Mod+Ctrl+Right" "Mod+Ctrl+L"])
              (noArgs "move-window-down" ["Mod+Ctrl+Down"])
              (noArgs "move-window-up" ["Mod+Ctrl+Up"])
              (noArgs "move-window-down-or-to-workspace-down" ["Mod+Ctrl+J"])
              (noArgs "move-window-up-or-to-workspace-up" ["Mod+Ctrl+K"])
              (noArgs "focus-column-first" ["Mod+Home"])
              (noArgs "focus-column-last" ["Mod+End"])
              (noArgs "move-column-to-first" ["Mod+Ctrl+Home"])
              (noArgs "move-column-to-last" ["Mod+Ctrl+End"])
              (noArgs "focus-monitor-left" ["Mod+Shift+Left" "Mod+Shift+H"])
              (noArgs "focus-monitor-right" ["Mod+Shift+Right" "Mod+Shift+L"])
              (noArgs "focus-monitor-down" ["Mod+Shift+Down" "Mod+Shift+J"])
              (noArgs "focus-monitor-up" ["Mod+Shift+Up" "Mod+Shift+K"])
              (noArgs "move-column-to-monitor-left" ["Mod+Shift+Ctrl+Left" "Mod+Shift+Ctrl+H"])
              (noArgs "move-column-to-monitor-right" ["Mod+Shift+Ctrl+Right" "Mod+Shift+Ctrl+L"])
              (noArgs "move-column-to-monitor-down" ["Mod+Shift+Ctrl+Down" "Mod+Shift+Ctrl+J"])
              (noArgs "move-column-to-monitor-up" ["Mod+Shift+Ctrl+Up" "Mod+Shift+Ctrl+K"])
              (noArgs "focus-workspace-down" ["Mod+Page_Down" "Mod+U"])
              (noArgs "focus-workspace-up" ["Mod+Page_Up" "Mod+I"])
              (noArgs "move-column-to-workspace-down" ["Mod+Ctrl+Page_Down" "Mod+Ctrl+U"])
              (noArgs "move-column-to-workspace-up" ["Mod+Ctrl+Page_Up" "Mod+Ctrl+I"])
              (noArgs "move-workspace-down" ["Mod+Shift+Page_Down" "Mod+Shift+U"])
              (noArgs "move-workspace-up" ["Mod+Shift+Page_Up" "Mod+Shift+I"])
              (noArgs "focus-column-left" ["Mod+WheelScrollDown"])
              (noArgs "focus-column-right" ["Mod+WheelScrollUp"])
              (noArgs "move-column-left" ["Mod+Ctrl+WheelScrollDown"])
              (noArgs "move-column-right" ["Mod+Ctrl+WheelScrollUp"])
              (noArgs "consume-or-expel-window-left" ["Mod+BracketLeft"])
              (noArgs "consume-or-expel-window-right" ["Mod+BracketRight"])
              (noArgs "expel-window-from-column" ["Mod+Period"])
              (noArgs "switch-preset-column-width" ["Mod+R"])
              (noArgs "switch-preset-window-height" ["Mod+Shift+R"])
              (noArgs "reset-window-height" ["Mod+Ctrl+R"])
              (noArgs "maximize-column" ["Mod+F"])
              (noArgs "fullscreen-window" ["Mod+Shift+F"])
              (noArgs "maximize-window-to-edges" ["Mod+M"])
              (noArgs "expand-column-to-available-width" ["Mod+Ctrl+F"])
              (noArgs "center-column" ["Mod+C"])
              (noArgs "center-visible-columns" ["Mod+Ctrl+C"])
              (noArgs "toggle-window-floating" ["Mod+V"])
              (noArgs "switch-focus-between-floating-and-tiling" ["Mod+Shift+V"])
              (noArgs "toggle-column-tabbed-display" ["Mod+W"])
              (noArgs "screenshot" ["Mod+Shift+S"])
              (noArgs "screenshot-screen" ["Mod+Ctrl+S"])
              (noArgs "screenshot-window" ["Mod+Alt+S"])
              (noArgs "toggle-keyboard-shortcuts-inhibit" ["Mod+Escape"])
              (noArgs "quit" ["Mod+Shift+E" "Ctrl+Alt+Delete"])
              (noArgs "power-off-monitors" ["Mod+Shift+P"])
              (lib.mkIf config.programs.noctalia-shell.enable {
                "Mod+Space" = {
                  _props.hotkey-overlay-title = "Open Launcher: noctalia-shell";
                  spawn-sh = "noctalia-shell ipc call launcher toggle";
                };
                "Mod+S" = {
                  _props.hotkey-overlay-title = "Open Control Centre: noctalia-shell";
                  spawn-sh = "noctalia-shell ipc call controlCenter toggle";
                };
                "Mod+Comma" = {
                  _props.hotkey-overlay-title = "Open Settings: noctalia-shell";
                  spawn-sh = "noctalia-shell ipc call settings toggle";
                };
                "Mod+Shift+W" = {
                  _props.hotkey-overlay-title = "Change Wallpaper: noctalia-shell";
                  spawn-sh = "noctalia-shell ipc call wallpaper toggle";
                };
                "Mod+Shift+M" = {
                  _props.hotkey-overlay-title = "Toggle Theme: noctalia-shell";
                  spawn-sh = "noctalia-shell ipc call darkMode toggle";
                };
                "XF86AudioRaiseVolume".spawn = ["noctalia-shell" "ipc" "call" "volume" "increase"];
                "XF86AudioLowerVolume".spawn = ["noctalia-shell" "ipc" "call" "volume" "decrease"];
                "XF86AudioMute".spawn = ["noctalia-shell" "ipc" "call" "volume" "muteOutput"];
                "XF86MonBrightnessUp".spawn = ["noctalia-shell" "ipc" "call" "brightness" "increase"];
                "XF86MonBrightnessDown".spawn = ["noctalia-shell" "ipc" "call" "brightness" "decrease"];
              })
              {
                "Mod+T" = {
                  _props.hotkey-overlay-title =
                    if defaultTerminal != null
                    then "Open a Terminal: ${defaultTerminal}"
                    else "Open a Terminal";
                  spawn = "xdg-terminal-exec";
                };
                "Mod+N" = {
                  _props.hotkey-overlay-title = "Open Neovim: nvim";
                  spawn = ["xdg-terminal-exec" "nvim"];
                };
                "Mod+Y" = {
                  _props.hotkey-overlay-title = "Open Yazi: yazi";
                  spawn = ["foot" "--title" "Yazi: ~/" "--" "yazi"];
                };
                "Mod+B" = {
                  _props.hotkey-overlay-title =
                    if defaultBrowser != null
                    then "Open Browser: ${defaultBrowser}"
                    else "Open Browser";
                  spawn = ["xdg-open" "https://"];
                };
                "XF86AudioPlay" = {
                  _props.allow-when-locked = true;
                  spawn-sh = "playerctl play-pause";
                };
                "XF86AudioStop" = {
                  _props.allow-when-locked = true;
                  spawn-sh = "playerctl stop";
                };
                "XF86AudioPrev" = {
                  _props.allow-when-locked = true;
                  spawn-sh = "playerctl previous";
                };
                "XF86AudioNext" = {
                  _props.allow-when-locked = true;
                  spawn-sh = "playerctl next";
                };
                "Mod+Shift+WheelScrollDown" = {
                  _props.cooldown-ms = 150;
                  focus-workspace-down = {};
                };
                "Mod+Shift+WheelScrollUp" = {
                  _props.cooldown-ms = 150;
                  focus-workspace-up = {};
                };
                "Mod+Ctrl+Shift+WheelScrollDown" = {
                  _props.cooldown-ms = 150;
                  move-column-to-workspace-down = {};
                };
                "Mod+Ctrl+Shift+WheelScrollUp" = {
                  _props.cooldown-ms = 150;
                  move-column-to-workspace-up = {};
                };
                "Mod+Minus".set-column-width = "-10%";
                "Mod+Equal".set-column-width = "+10%";
                "Mod+Shift+Minus".set-window-height = "-10%";
                "Mod+Shift+Equal".set-window-height = "+10%";
              }
              (lib.listToAttrs (map (workspace: {
                name = "Mod+${toString workspace}";
                value = bind "focus-workspace" workspace;
              }) (lib.range 1 9)))
              (lib.listToAttrs (map (workspace: {
                name = "Mod+Ctrl+${toString workspace}";
                value = bind "move-column-to-workspace" workspace;
              }) (lib.range 1 9)))
            ];

            spawn-at-startup = lib.mkIf config.programs.noctalia-shell.enable "noctalia-shell";
            spawn-sh-at-startup = lib.mkIf isUtm "spice-vdagent -x";
          };
        };
      })
    ];
  };
}
