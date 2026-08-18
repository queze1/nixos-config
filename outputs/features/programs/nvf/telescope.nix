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
          defaults.vimgrep_arguments = lib.mkForce [
            "${pkgs.ripgrep}/bin/rg"
            "--color=never"
            "--no-heading"
            "--with-filename"
            "--line-number"
            "--column"
            "--smart-case"
            "--hidden"
          ];

          extensions = {
            live_grep_args = {
              auto_quoting = true;
              mappings = lib.mkLuaInline ''
                {
                  i = {
                    ["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
                    ["<C-w>"] = require("telescope-live-grep-args.actions").quote_prompt({ postfix = ' --word-regexp' }),
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
          desc = "Live grep (args) [Telescope]";
          silent = true;
        }
        {
          key = "<Leader>gc";
          mode = "n";
          action = "<cmd>lua require('telescope-live-grep-args.shortcuts').grep_word_under_cursor()<CR>";
          desc = "Grep word under cursor [Telescope]";
          silent = true;
        }
      ];
    };
  };
}
