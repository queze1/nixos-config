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
              mappings = {
                i = {
                  "C-K" = lib.mkLuaInline ''require("telescope-live-grep-args.actions").quote_prompt()'';
                };
              };
            };
          };
        };
      };

      # Additional Telescope keybinds
      keymaps = [
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
          action = "<cmd>lua require(\"telescope\").extensions.live_grep_args.live_grep_args()<CR>";
          desc = "Live Grep (args) [Telescope]";
          silent = true;
        }
      ];
    };
  };
}
