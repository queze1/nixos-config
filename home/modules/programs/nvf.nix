{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  neovim-project = pkgs.vimUtils.buildVimPlugin {
    name = "neovim-project";
    src = pkgs.fetchFromGitHub {
      owner = "coffebar";
      repo = "neovim-project";
      # Last updated 24/05/2026
      rev = "6ecf6253697b2964e9afef9d000357d887221a2c";
      sha256 = "sha256-.........................................."; # Run once, Nix will tell you the correct hash
    };
  };
in
{
  imports = [ inputs.nvf.homeManagerModules.default ];

  # Set Neovim as default editor
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        # ----------------------------------------
        # General
        # ----------------------------------------
        opts = {
          shiftwidth = 4;
          tabstop = 4;
        };
        # Yank into system keyboard
        clipboard = {
          enable = true;
          registers = "unnamedplus";
        };
        binds.whichKey.enable = true;

        # ----------------------------------------
        # Appearance
        # ----------------------------------------
        theme = {
          enable = true;
          name = "catppuccin";
          style = "mocha";
        };
        statusline.lualine.enable = true;

        # ----------------------------------------
        # Languages
        # ----------------------------------------
        lsp.enable = true;
        languages = {
          java.enable = true;
          markdown = {
            enable = true;
            extensions.render-markdown-nvim.enable = true;
          };
          nix.enable = true;
          python.enable = true;
          rust.enable = true;
          typescript.enable = true;
        };
        treesitter = {
          enable = true;
          context.enable = true;
          grammars = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
            kdl
            regex
          ];
        };

        # ----------------------------------------
        # Editing
        # ----------------------------------------
        autocomplete.nvim-cmp.enable = true;
        utility.surround.enable = true;
        autopairs.nvim-autopairs.enable = true;

        # Autoformat on save
        formatter.conform-nvim.enable = true;
        lsp.formatOnSave = true;

        # Paste images from system clipboard
        utility.images.img-clip.enable = true;

        # ----------------------------------------
        # Navigation
        # ----------------------------------------
        # Jumping
        utility.motion.flash-nvim.enable = true;

        # Fuzzy finding
        telescope.enable = true;

        # File swapping
        navigation.harpoon = {
          enable = true;
          mappings = {
            markFile = "<leader>m";
            listMarks = "<leader>e";
            file1 = "<leader>1";
            file2 = "<leader>2";
            file3 = "<leader>3";
            file4 = "<leader>4";
          };
        };

        # File navigation
        utility.yazi-nvim = {
          enable = true;
          mappings = {
            openYazi = "<leader>-";
            openYaziDir = "<leader>cw";
            yaziToggle = "<c-up>";
          };
          setupOpts = {
            open_for_directories = true;
          };
        };

        # ----------------------------------------
        # Integrations
        # ----------------------------------------
        # Open and close terminals easily
        terminal.toggleterm = {
          enable = true;
          mappings.open = "<C-t>";

          lazygit.enable = true;
          lazygit.mappings.open = "<leader>gg";
        };

        # Git integration
        git.enable = true;
        utility.diffview-nvim.enable = true;

        # Copilot integration
        assistant = {
          copilot.enable = true;
          codecompanion-nvim = {
            enable = true;
          };
        };

        # Direnv integration
        utility.direnv.enable = true;

        # ----------------------------------------
        # Extra Plugins
        # ----------------------------------------
        extraPlugins = with pkgs.vimPlugins; {
          # Smooth scrolling
          neoscroll = {
            package = neoscroll-nvim;
            setup = ''
              neoscroll = require('neoscroll')
              neoscroll.setup({
                easing = 'sine',
              })

              -- Set scrolling animations
              local keymap = {
                ["<C-u>"] = function() neoscroll.ctrl_u({ duration = 150 }) end; -- 250 default
                ["<C-d>"] = function() neoscroll.ctrl_d({ duration = 150 }) end; -- 250 default
                ["<C-b>"] = function() neoscroll.ctrl_b({ duration = 450 }) end;
                ["<C-f>"] = function() neoscroll.ctrl_f({ duration = 450 }) end;
                ["<C-y>"] = function() neoscroll.scroll(-0.1, { move_cursor=false; duration = 100 }) end;
                ["<C-e>"] = function() neoscroll.scroll(0.1, { move_cursor=false; duration = 100 }) end;
                ["zt"]    = function() neoscroll.zt({ half_win_duration = 150 }) end; -- 250 default
                ["zz"]    = function() neoscroll.zz({ half_win_duration = 150 }) end; -- 250 default
                ["zb"]    = function() neoscroll.zb({ half_win_duration = 150 }) end; -- 250 default
              }
              local modes = { 'n', 'v', 'x' }
              for key, func in pairs(keymap) do
                vim.keymap.set(modes, key, func)
              end
            '';
          };

          neovim-project = {
            package = neovim-project;
            setup = "";
          };

          # Move based on indentation
          vim-indentwise = {
            package = vim-indentwise;
            setup = "";
          };
        };

        # ----------------------------------------
        # Keybinds
        # ----------------------------------------
        augroups = [
          {
            name = "close_with_q";
            clear = true;
          }
        ];

        # Close special buffers with 'q'
        autocmds = [
          {
            event = [ "FileType" ];
            group = "close_with_q";
            pattern = [
              # Use :set ft? to find FileType
              "checkhealth"
              "help"
              "lspinfo"
              "man"
              "qf"
            ];
            callback = lib.generators.mkLuaInline ''
              function(event)
                vim.keymap.set("n", "q", "<cmd>close<cr>", { 
                  buffer = event.buf, 
                  silent = true,
                  desc = "Close special buffer" 
                })
              end
            '';
          }
          # {
          #   event = [ "User" ];
          #   pattern = [
          #     "DirenvLoaded"
          #   ];
          #   callback = lib.generators.mkLuaInline ''
          #     function()
          #       vim.cmd("lsp restart")
          #       print("Direnv environment loaded!")
          #     end
          #   '';
          # }
        ];

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
          # Clear search highlights with ESC
          {
            key = "<Esc>";
            mode = "n";
            action = "<Cmd>nohlsearch<CR>";
            silent = true;
            desc = "Clear search highlights";
          }
          # CodeCompanion keybinds
          {
            key = "<C-a>";
            mode = [
              "n"
              "v"
            ];
            action = "<cmd>CodeCompanionActions<cr>";
            silent = true;
            desc = "Open CodeCompanion actions";
          }
          {
            key = "<Leader>a";
            mode = [
              "n"
              "v"
            ];
            action = "<cmd>CodeCompanionChat Toggle<cr>";
            silent = true;
            desc = "Toggle CodeCompanion Chat";
          }
          {
            key = "ga";
            mode = [ "v" ];
            action = "<cmd>CodeCompanionChat Add<cr>";
            silent = true;
            desc = "Add selected text to CodeCompanion Chat";
          }
          {
            key = "cc";
            mode = "ca";
            action = "CodeCompanion";
            silent = true;
          }
        ];

        # Workaround for bugged Harpoon WhichKey
        binds.whichKey.register = {
          "<leader>a" = lib.mkForce "Toggle CodeCompanion Chat";
          "<leader>m" = "Mark file [Harpoon]";
        };
      };
    };
  };
}
