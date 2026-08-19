{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  isUtm = config.my.utm.enable;
in {
  imports = [inputs.niri.nixosModules.niri];

  config = lib.mkIf config.my.desktop.enable {
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };

    niri-flake.cache.enable = false;

    home-manager.sharedModules = [
      ({config, ...}: let
        bind = action: args: {action = {${action} = args;};};
        noArgs = action: keys: lib.genAttrs keys (_: bind action []);
        browser = lib.removeSuffix ".desktop" (config.xdg.mimeApps.defaultApplications."x-scheme-handler/https" or "Default Browser");
      in {
        programs.niri.settings = {
          input = {
            keyboard.numlock = true;
            touchpad = {
              tap = true;
              natural-scroll = true;
            };
            workspace-auto-back-and-forth = true;
            focus-follows-mouse = {
              enable = true;
              max-scroll-amount = "10%";
            };
          };

          outputs."Virtual-1" = {
            mode = {
              width = 2560;
              height = 1664;
              refresh = 60.0;
            };
            scale = 2.0;
          };

          layout = {
            gaps = 12;
            center-focused-column = "never";
            preset-column-widths = [
              {proportion = 0.5;}
              {proportion = 0.33333;}
              {proportion = 0.66667;}
            ];
            preset-window-heights = [
              {proportion = 0.5;}
              {proportion = 0.33333;}
              {proportion = 0.66667;}
              {proportion = 1.0;}
            ];
            default-column-width.proportion = 0.5;
            focus-ring = {
              enable = false;
              width = 4;
              active.color = "#7fc8ff";
              inactive.color = "#505050";
            };
            border = {
              width = 3;
              active.color = "#7fc8ff";
              inactive.color = "#505050";
              urgent.color = "#9b0000";
            };
            shadow = {
              enable = true;
              softness = 30;
              spread = 5;
              offset = {
                x = 0;
                y = 5;
              };
              color = "#0007";
            };
          };

          prefer-no-csd = true;
          screenshot-path = "/mnt/utm/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

          window-rules = [
            {
              matches = [{app-id = "^org\\.wezfurlong\\.wezterm$";}];
              default-column-width = {};
            }
            {
              matches = [
                {
                  app-id = "firefox$";
                  title = "^Picture-in-Picture$";
                }
              ];
              open-floating = true;
            }
            {
              matches = [{app-id = "^org\\.keepassxc\\.KeePassXC$";}];
              block-out-from = "screen-capture";
            }
            {
              matches = [
                {
                  app-id = "foot";
                  title = "^Yazi:.*";
                }
              ];
              default-column-width.proportion = 1.0;
            }
            {
              matches = [{app-id = "imv";}];
              default-column-width.proportion = 1.0;
            }
          ];

          binds = lib.mkMerge [
            (noArgs "show-hotkey-overlay" ["Mod+Shift+Slash"])
            (lib.recursiveUpdate (noArgs "toggle-overview" ["Mod+O"]) {"Mod+O".repeat = false;})
            (lib.recursiveUpdate (noArgs "close-window" ["Mod+Q"]) {"Mod+Q".repeat = false;})
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
                action.spawn-sh = "noctalia-shell ipc call launcher toggle";
                hotkey-overlay.title = "Open Launcher: noctalia-shell";
              };
              "Mod+S" = {
                action.spawn-sh = "noctalia-shell ipc call controlCenter toggle";
                hotkey-overlay.title = "Open Control Centre: noctalia-shell";
              };
              "Mod+Comma" = {
                action.spawn-sh = "noctalia-shell ipc call settings toggle";
                hotkey-overlay.title = "Open Settings: noctalia-shell";
              };
              "Mod+Shift+W" = {
                action.spawn-sh = "noctalia-shell ipc call wallpaper toggle";
                hotkey-overlay.title = "Change Wallpaper: noctalia-shell";
              };
              "Mod+Shift+M" = {
                action.spawn-sh = "noctalia-shell ipc call darkMode toggle";
                hotkey-overlay.title = "Toggle Theme: noctalia-shell";
              };
              "XF86AudioRaiseVolume".action.spawn = ["noctalia-shell" "ipc" "call" "volume" "increase"];
              "XF86AudioLowerVolume".action.spawn = ["noctalia-shell" "ipc" "call" "volume" "decrease"];
              "XF86AudioMute".action.spawn = ["noctalia-shell" "ipc" "call" "volume" "muteOutput"];
              "XF86MonBrightnessUp".action.spawn = ["noctalia-shell" "ipc" "call" "brightness" "increase"];
              "XF86MonBrightnessDown".action.spawn = ["noctalia-shell" "ipc" "call" "brightness" "decrease"];
            })
            {
              "Mod+T" = {
                action.spawn = "xdg-terminal-exec";
                hotkey-overlay.title = "Open a Terminal";
              };
              "Mod+N" = {
                action.spawn = ["xdg-terminal-exec" "nvim"];
                hotkey-overlay.title = "Open Neovim: nvim";
              };
              "Mod+Y" = {
                action.spawn = ["foot" "--title" "Yazi: ~/" "--" "yazi"];
                hotkey-overlay.title = "Open Yazi: yazi";
              };
              "Mod+B" = {
                action.spawn = ["xdg-open" "https://"];
                hotkey-overlay.title = "Open ${browser}";
              };
              "XF86AudioPlay" = {
                action.spawn-sh = "playerctl play-pause";
                allow-when-locked = true;
              };
              "XF86AudioStop" = {
                action.spawn-sh = "playerctl stop";
                allow-when-locked = true;
              };
              "XF86AudioPrev" = {
                action.spawn-sh = "playerctl previous";
                allow-when-locked = true;
              };
              "XF86AudioNext" = {
                action.spawn-sh = "playerctl next";
                allow-when-locked = true;
              };
              "Mod+Shift+WheelScrollDown" = {
                action.focus-workspace-down = [];
                cooldown-ms = 150;
              };
              "Mod+Shift+WheelScrollUp" = {
                action.focus-workspace-up = [];
                cooldown-ms = 150;
              };
              "Mod+Ctrl+Shift+WheelScrollDown" = {
                action.move-column-to-workspace-down = [];
                cooldown-ms = 150;
              };
              "Mod+Ctrl+Shift+WheelScrollUp" = {
                action.move-column-to-workspace-up = [];
                cooldown-ms = 150;
              };
              "Mod+Minus".action.set-column-width = "-10%";
              "Mod+Equal".action.set-column-width = "+10%";
              "Mod+Shift+Minus".action.set-window-height = "-10%";
              "Mod+Shift+Equal".action.set-window-height = "+10%";
            }
            (lib.genAttrs (map toString (lib.range 1 9)) (workspace: bind "focus-workspace" (builtins.fromJSON workspace)))
            (lib.genAttrs (map (workspace: "Mod+Ctrl+${workspace}") (map toString (lib.range 1 9))) (key: bind "move-column-to-workspace" (builtins.fromJSON (lib.last (lib.splitString "+" key)))))
          ];

          spawn-at-startup =
            lib.optionals config.programs.noctalia-shell.enable [{argv = ["noctalia-shell"];}]
            ++ lib.optionals isUtm [{sh = "spice-vdagent -x";}];
        };

        home.packages = with pkgs; [
          xwayland-satellite
        ];
      })
    ];
  };
}
