{ inputs, ... }:
{
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
    plugins.recycle-bin = "${inputs.recycle-bin-yazi}";
    initLua = ''
      require("bunny"):setup({
        hops = {
          { key = "/",          path = "/",                                      },
          { key = "~",          path = "~",                                      },
          { key = "t",          path = "/tmp",                                   },
          { key = ".",          path = "~/.config",                              },
          { key = "n",          path = "/nix/store",         desc = "Nix store"  },
          { key = "c",          path = "~/etc/nixos",        desc = "Nix config" },
          { key = "C",          path = "~/Coding",           desc = "Coding"     },
          { key = "m",          path = "/mnt/utm/Music",                         },
          { key = "d",          path = "/mnt/utm/Downloads",                     },
          { key = "D",          path = "/mnt/utm/Documents",                     },
          { key = "p",          path = "/mnt/utm/Pictures",                      },
          { key = "v",          path = "/mnt/utm/Videos",                        },
          { key = "o",          path = "/mnt/utm/Documents/obsidian",            },
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
        on = [ "T" ];
        run = "shell 'xdg-terminal-exec' --orphan";
        desc = "Open terminal in current directory";
      }
      {
        on = "<C-y>";
        run = "plugin system-clipboard";
        desc = "Copy to system clipboard";
      }
      {
        on = [
          "R"
          "b"
        ];
        run = "plugin recycle-bin";
        desc = "Open Recycle Bin menu";
      }
    ];
  };
}
