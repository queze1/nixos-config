{
  flake.homeModules.nvf = {pkgs, ...}: {
    home.packages = [pkgs.ripgrep];

    programs.nvf.settings.vim = {
      telescope = {
        enable = true;
        extensions = [
          {
            name = "live_grep_args";
            packages = [pkgs.vimPlugins.telescope-live-grep-args-nvim];
            setup.live_grep_args = {
              auto_quoting = true;
              additional_args = ["--smart-case" "--hidden"];
              mappings = {
                i = {
                  "<C-k>" = "lga_actions.quote_prompt()";
                  # Freeze the current list and start a fuzzy search in the frozen list
                  "<C-space>" = "lga_actions.to_fuzzy_refine";
                };
              };
            };
          }
        ];
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
