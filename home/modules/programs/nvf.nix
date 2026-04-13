{ inputs, pkgs, ... }:
{
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        autocomplete.nvim-cmp.enable = true;
        lsp.enable = true;

        # ----------------------------------------
        # Hot keys
        # ----------------------------------------
        keymaps = [
          # Ctrl-S to save
          {
            key = "<C-s>";
            mode = [
              "n"
              "i"
              "v"
            ];
            action = "<Cmd>w<CR>";
            silent = true;
            desc = "Save file";
          }
          # Insert newline above or below without entering insert mode
          {
            key = "<leader>o";
            mode = "n";
            action = "o<Esc>";
            silent = true;
            desc = "Insert newline below";
          }
          {
            key = "<leader>O";
            mode = "n";
            action = "O<Esc>";
            silent = true;
            desc = "Insert newline above";
          }
          # H to go to start (^), L to go to end ($)
          {
            key = "H";
            mode = [
              "n"
              "v"
            ];
            action = "^";
            silent = true;
            desc = "Go to start of line";
          }
          {
            key = "L";
            mode = [
              "n"
              "v"
            ];
            action = "$";
            silent = true;
            desc = "Go to end of line";
          }
        ];

        # ----------------------------------------
        # Features & Plugins
        # ----------------------------------------

        # Multi-cursor
        utility.multicursors.enable = true;

        # Surround with braces/brackets
        utility.surround.enable = true;

        # Yank into system keyboard
        clipboard = {
          enable = true;
          registers = "unnamedplus";
        };

        # Jumping (flash.nvim)
        utility.motion.flash-nvim.enable = true;

        extraPlugins = with pkgs.vimPlugins; {
          # Ability to move based on indentation (vim-indentwise)
          vim-indentwise = {
            package = vim-indentwise;
            setup = "";
          };

          # Smooth scrolling (neoscroll)
          # neoscroll = {
          #   package = neoscroll-nvim;
          #   setup = ''
          #     neoscroll = require('neoscroll')
          #     neoscroll.setup({
          #       easing = 'quadratic',
          #     })
          #
          #     -- Set scrolling animations
          #     local keymap = {
          #       ["<C-u>"] = function() neoscroll.ctrl_u({ duration = 250 }) end;
          #       ["<C-d>"] = function() neoscroll.ctrl_d({ duration = 250 }) end;
          #       ["<C-b>"] = function() neoscroll.ctrl_b({ duration = 450 }) end;
          #       ["<C-f>"] = function() neoscroll.ctrl_f({ duration = 450 }) end;
          #       ["<C-y>"] = function() neoscroll.scroll(-0.1, { move_cursor=false; duration = 100 }) end;
          #       ["<C-e>"] = function() neoscroll.scroll(0.1, { move_cursor=false; duration = 100 }) end;
          #       ["zt"]    = function() neoscroll.zt({ half_win_duration = 150 }) end; -- 250 default
          #       ["zz"]    = function() neoscroll.zz({ half_win_duration = 150 }) end; -- 250 default
          #       ["zb"]    = function() neoscroll.zb({ half_win_duration = 150 }) end; -- 250 default
          #     }
          #     local modes = { 'n', 'v', 'x' }
          #     for key, func in pairs(keymap) do
          #       vim.keymap.set(modes, key, func)
          #     end
          #   '';
          # };
        };

        # A tree plugin (neo-tree)
        filetree.neo-tree.enable = true;

        # Language highlighting and support (tree-sitter)
        treesitter.enable = true;
        treesitter.context.enable = true; # Shows sticky function/class context at the top

        # Autoformat on save (conform.nvim)
        formatter.conform-nvim.enable = true;
        lsp.formatOnSave = true;

        # Fuzzy finding (Telescope)
        telescope.enable = true;

        # Going to a previous file/project on start (session-manager)
        session.nvim-session-manager.enable = true;

        # Swapping between files like VSCode tabs (Harpoon)
        navigation.harpoon = {
          enable = true;
          mappings = {
            markFile = "<leader>a";
            listMarks = "<C-e>";
            file1 = "<C-j>";
            file2 = "<C-k>";
            file3 = "<C-l>";
            file4 = "<C-m>";
          };
        };

        # Enable smooth scrolling
        visuals.cinnamon-nvim = {
          enable = true;
          setupOpts.keymaps.basic = true;
        };
        options.wrap = false; # interferes with cinnamon

        # Copilot integration
        assistant.copilot = {
          enable = true;
          cmp.enable = true; # Intercepts nvim-cmp to provide inline suggestions within autocomplete
        };

        # Being able to open and close a terminal easily (ToggleTerm + hotkeys)
        terminal.toggleterm = {
          enable = true;
          mappings.open = "<C-t>";

          # Optional: Run lazygit inside toggleterm automatically
          lazygit.enable = true;
          lazygit.mappings.open = "<leader>gg";
        };

        # Git integration
        git.enable = true;

        # Ability to see git history of a file and copy paste from it (diffview)
        utility.diffview-nvim.enable = true;

        # Keybinding help (which-key)
        binds.whichKey.enable = true;
      };
    };
  };
}
