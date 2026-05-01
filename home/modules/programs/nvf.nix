{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.generators) mkLuaInline;
in
{
  imports = [ inputs.nvf.homeManagerModules.default ];

  home.sessionVariables = {
    # Set Neovim as default editor
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

        # ----------------------------------------
        # Appearance
        # ----------------------------------------
        theme = {
          enable = true;
          transparent = true;
          name = "catppuccin";
          style = "mocha";
        };
        statusline.lualine.enable = true;
        visuals.indent-blankline = {
          enable = true;
        };

        # ----------------------------------------
        # Languages
        # ----------------------------------------
        languages = {
          java.enable = true;
          markdown = {
            enable = true;
            extensions.render-markdown-nvim.enable = true;
          };
          nix.enable = true;
          python = {
            enable = true;
            # We manually configure Python formatting elsewhere
            format.enable = false;
          };
          rust.enable = true;
          typescript.enable = true;
        };

        lsp = {
          enable = true;
          lspconfig.enable = true;
          formatOnSave = true;
          servers = {
            basedpyright = {
              settings = {
                basedpyright = {
                  disableOrganizeImports = true;
                };
              };

              # Replace commands created by nvf
              # LspPyrightOrganizeImports: made redundant by ruff
              # LspPyrightSetPythonPath: made redundant by direnv
              on_attach = lib.mkForce (mkLuaInline ''
                function(client, bufnr)
                  vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightWriteBaseline', function()
                    vim.fn.jobstart({ "${lib.getExe pkgs.basedpyright}", "--writebaseline" }, {
                      cwd = client.config.root_dir,
                      on_exit = function(_, code)
                        if code == 0 then
                          vim.notify("basedpyright: baseline written", vim.log.levels.INFO)
                        else
                          vim.notify("basedpyright: baseline failed", vim.log.levels.ERROR)
                        end
                      end
                    })
                  end, { desc = 'Run basedpyright --writebaseline' })
                end
              '');
            };
          };
        };

        # Autoformat on save
        formatter.conform-nvim = {
          enable = true;
          setupOpts = {
            formatters_by_ft = {
              # Uses ruff in PATH
              python = [
                "ruff_fix"
                "ruff_format"
                "ruff_organize_imports"
              ];
            };
          };
        };

        treesitter = {
          enable = true;
          context.enable = true;
          textobjects.enable = true;
          grammars = with pkgs.vimPlugins.nvim-treesitter; [
            withAllGrammars
          ];
        };

        # ----------------------------------------
        # Editing
        # ----------------------------------------
        autocomplete.nvim-cmp.enable = true;
        utility.surround.enable = true;
        autopairs.nvim-autopairs.enable = true;

        # Paste images from system clipboard
        utility.images.img-clip.enable = true;

        # ----------------------------------------
        # Navigation
        # ----------------------------------------
        # Search case-insensitive unless a capital letter is used
        searchCase = "smart";

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

        # Session and project management
        session.nvim-session-manager = {
          enable = true;
          # May cause confusion as both project.nvim and session-manager can open a selection menu for sessions/projects
          # By default, loadSession is overwritten
          # mappings = {
          #   loadSession = "<leader>ss";
          #   loadLastSession = "<leader>sl";
          # };
        };
        projects.project-nvim = {
          enable = true;
          setupOpts = {
            manual_mode = false;
          };
        };

        # ----------------------------------------
        # Integrations
        # ----------------------------------------
        # Open and close terminals easily
        terminal.toggleterm = {
          enable = true;
          setupOpts = {
            shell = lib.getExe pkgs.fish;
          };

          lazygit.enable = true;
          lazygit.mappings.open = "<leader>gg";
        };

        # Git integration
        git.enable = true;
        utility.diffview-nvim.enable = true;

        # LLM integration
        assistant = {
          codecompanion-nvim = {
            enable = true;
            setupOpts = {
              interactions = {
                chat = {
                  adapter = {
                    name = "copilot";
                    model = "gpt-5.2-codex";
                  };
                };
                inline = {
                  adapter = "copilot";
                  model = "gpt-5.2-codex";
                };
              };
              adapters = lib.mkLuaInline ''
                {
                  ["http"]= {
                    ["tavily"] = function()
                      return require("codecompanion.adapters").extend("tavily", {
                        env = {
                          api_key = "cmd:cat ${config.age.secrets.tavily-api-key.path}",
                        },
                      })
                    end,
                  },
                }
              '';
            };
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
          # Reload LSPs after loading direnv
          {
            event = [ "User" ];
            pattern = [
              "DirenvLoaded"
            ];
            callback = lib.generators.mkLuaInline ''
              function()
                local cwd = vim.fn.getcwd()
                
                -- Skip if we have already restarted the LSP for this directory
                if vim.g.last_direnv_path == cwd then
                  return
                end

                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if #clients > 0 then
                  vim.cmd("lsp restart")
                  vim.g.last_direnv_path = cwd
                end
              end
            '';
          }
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

        binds.whichKey = {
          enable = true;
          register = {
            # Workaround for bugged Harpoon WhichKey
            "<leader>a" = lib.mkForce "Toggle CodeCompanion Chat";
            "<leader>m" = "Mark file [Harpoon]";
          };
        };

        luaConfigRC.whichkey-visual = ''
          local wk = require("which-key")
          wk.add({
            { "*", mode = "v", desc = "Search selection forward" },
            { "#", mode = "v", desc = "Search selection backward" },
            { "@", mode = "v", desc = "Run macro on selection" },
            { "Q", mode = "v", desc = "Repeat last macro on selection" },
            { ";", mode = "v", desc = "Repeat char jump (forward)" },
            { ",", mode = "v", desc = "Repeat char jump (backward)" },
          })
        '';
      };
    };
  };
}
