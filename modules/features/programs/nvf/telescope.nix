{
  flake.homeModules.nvf = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = [pkgs.ripgrep];

    programs.nvf.settings.vim = {
      telescope = {
        enable = true;
        extensions = [
          {
            name = "live_grep_args";
            packages = [pkgs.vimPlugins.telescope-live-grep-args-nvim];
          }
        ];
        setupOpts = {
          extensions = {
            live_grep_args = {
              auto_quoting = true;
              additional_args = ["--smart-case" "--hidden"];
              mappings = lib.mkLuaInline ''
                {
                  i = {
                    ["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
                  },
                }
              '';
            };
          };
        };
      };

      # Hack to add Telescope keybinds using internal interface
      # Telescope is lazy loaded, regular keymaps won't trigger a load
      # Use lib.mkAfter to override default keybinds
      lazy.plugins.telescope.keys = lib.mkAfter [
        {
          key = "<Leader>fo";
          mode = "n";
          action = "<cmd>Telescope oldfiles<CR>";
          desc = "Find old files [Telescope]";
          silent = true;
        }
        {
          key = "<Leader>fg";
          mode = "n";
          action = "<cmd>Telescope live_grep_args<CR>";
          desc = "Live Grep (args) [Telescope]";
          silent = true;
        }
      ];
    };
  };
}
