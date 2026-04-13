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
          # Ctrl-D/U to scroll and then centre
          {
            key = "<C-d>";
            mode = [
              "n"
              "v"
            ];
            action = "<C-d>zz";
            silent = true;
            desc = "Scroll down and center";
          }
          {
            key = "<C-u>";
            mode = [
              "n"
              "v"
            ];
            action = "<C-u>zz";
            silent = true;
            desc = "Scroll up and center";
          }
          # Shortcut to insert newline above or below without entering insert mode
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

        # Ability to move based on indentation (vim-indentwise)
        # Since this plugin isn't natively exposed via a toggle in nvf yet, we add it via extraPlugins.
        # It provides `[-`, `]+`, `[=`, `]=` bindings out of the box for jump to inner / jump to same
        extraPlugins = with pkgs.vimPlugins; {
          vim-indentwise = {
            package = vim-indentwise;
            setup = "";
          };
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

        # Being able to go to a previous file/project on start (session-manager)
        session.nvim-session-manager.enable = true;

        # Being able to easily swap between files like VSCode tabs (Harpoon)
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
        # Enables a full suite of Git tools including gitsigns, vim-fugitive, and git-conflict
        git.enable = true;

        # Ability to see git history of a file and copy paste from it (diffview)
        utility.diffview-nvim.enable = true;

        # Keybinding help (which-key)
        binds.whichKey.enable = true;
      };
    };
  };
}
