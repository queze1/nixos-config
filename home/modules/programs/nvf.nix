{ inputs, pkgs, ... }:
{
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        lsp.enable = true;
        languages = {
          python.enable = true;
          rust.enable = true;
          java.enable = true;
          nix.enable = true;
        };

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
              "o"
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
              "o"
            ];
            action = "$";
            silent = true;
            desc = "Go to end of line";
          }
          # Window navigation
          {
            key = "<C-h>";
            mode = "n";
            action = "<C-w>h";
            silent = true;
            desc = "Move to window left";
          }
          {
            key = "<C-j>";
            mode = "n";
            action = "<C-w>j";
            silent = true;
            desc = "Move to window down";
          }
          {
            key = "<C-k>";
            mode = "n";
            action = "<C-w>k";
            silent = true;
            desc = "Move to window up";
          }
          {
            key = "<C-l>";
            mode = "n";
            action = "<C-w>l";
            silent = true;
            desc = "Move to window right";
          }
        ];

        # ----------------------------------------
        # Features & Plugins
        # ----------------------------------------
        comments.comment-nvim.enable = true;
        autocomplete.nvim-cmp.enable = true;

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
            file1 = "<leader>1";
            file2 = "<leader>2";
            file3 = "<leader>3";
            file4 = "<leader>4";
          };
        };

        # Enable smooth scrolling
        visuals.cinnamon-nvim = {
          enable = true;
          setupOpts.keymaps.basic = true;
        };
        options.wrap = false; # interferes with cinnamon

        # Copilot integration
        assistant = {
          copilot.enable = true;
          avante-nvim = {
            enable = true;
            setupOpts = {
              provider = "copilot";
            };
          };
        };

        # Open and close terminals easily
        terminal.toggleterm = {
          enable = true;
          mappings.open = "<C-t>";

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
