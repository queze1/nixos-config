{inputs, ...}: {
  flake.homeModules.yazi = {config, ...}: let
    cfg = config.xdg.userDirs;
  in {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";

      # Allow changing images in imv
      settings = {
        opener = {
          imv = [
            {
              run = ''imv -n "$1" .'';
              desc = "View image in imv";
            }
          ];
        };
        open = {
          prepend_rules = [
            {
              mime = "image/*";
              use = [
                "imv"
                "view"
              ];
            }
          ];
        };
      };

      plugins.bunny = "${inputs.bunny-yazi}";
      plugins.system-clipboard = "${inputs.system-clipboard-yazi}";
      # TODO: The recommended way to get [XDG user directories] is via the xdg-user-dir command or by processing $XDG_CONFIG_HOME/user-dirs.dirs directly in your application.
      initLua = ''
        require("bunny"):setup({
          hops = {
            { key = "/",          path = "/",                                                 },
            { key = "t",          path = "/tmp",                                              },
            { key = "n",          path = "/nix/store",         desc = "Nix store"             },
            { key = "~",          path = "~",                                                 },
            { key = "c",          path = "~/.config",          desc = "Config files"          },
            { key = { "l", "s" }, path = "~/.local/share",     desc = "Local share"           },
            { key = { "l", "b" }, path = "~/.local/bin",       desc = "Local bin"             },
            { key = { "l", "t" }, path = "~/.local/state",     desc = "Local state"           },
            { key = "C",          path = "~/Coding",           desc = "Coding"                },
            { key = "m",          path = "${cfg.music}",       desc = "Music"                 },
            { key = "d",          path = "${cfg.downloads}",   desc = "Downloads"             },
            { key = "D",          path = "${cfg.documents}",   desc = "Documents"             },
            { key = "p",          path = "${cfg.pictures}",    desc = "Pictures"              },
            { key = "v",          path = "${cfg.videos}",      desc = "Videos"                },
            { key = "o",          path = "${cfg.documents}/obsidian", desc = "Obsidian vault" },
          },
          desc_strategy = "path", -- If desc isn't present, use "path" or "filename", default is "path"
          ephemeral = true, -- Enable ephemeral hops, default is true
          tabs = true, -- Enable tab hops, default is true
          notify = false, -- Notify after hopping, default is false
          fuzzy_cmd = "fzf", -- Fuzzy searching command, default is "fzf"
        })
      '';

      keymap.mgr.prepend_keymap = [
        {
          on = ";";
          run = "plugin bunny";
          desc = "Start bunny.yazi";
        }
        {
          on = ["T"];
          run = "shell 'xdg-terminal-exec' --orphan";
          desc = "Open terminal in current directory";
        }
        {
          on = "<C-y>";
          run = "plugin system-clipboard";
          desc = "Copy to system clipboard";
        }
      ];
    };
  };
}
