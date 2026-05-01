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
  imports = [
    inputs.nvf.homeManagerModules.default
    ./keybinds.nix
  ];

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

        # Open files unfolded initially
        luaConfigRC.foldLevelStart = ''
          vim.opt.foldlevelstart = 99
        '';

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
          fold = true;
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
        session.nvim-session-manager.enable = true;
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
          # Autocomplete for command line
          cmp-cmdline = {
            package = cmp-cmdline;
            setup = ''
              local cmp = require('cmp')
              cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                  { name = 'path' }
                },
                {
                  {
                    name = 'cmdline',
                    option = {
                      ignore_cmds = { 'Man', '!' }
                    }
                  }
                })
              })
            '';
          };

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

          # Needed as treesitter.textobjects is broken
          nvim-treesitter-textobjects = {
            package = nvim-treesitter-textobjects;
            setup = ''
              require("nvim-treesitter-textobjects").setup({
                select = {
                  enable = true,
                  -- Automatically jump forward to textobj, similar to targets.vim
                  lookahead = true,

                  selection_modes = {
                    ['@parameter.outer'] = 'v', -- charwise
                    ['@function.outer'] = 'V', -- linewise
                  },

                  -- If you set this to `true` (default is `false`) then any textobject is
                  -- extended to include preceding or succeeding whitespace.
                  include_surrounding_whitespace = false,
                },
              })

              -- f: function
              vim.keymap.set({ "x", "o" }, "af", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
              end, { desc = "function [Treesitter]" })

              vim.keymap.set({ "x", "o" }, "if", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
              end, { desc = "function [Treesitter]" })

              -- c: class
              vim.keymap.set({ "x", "o" }, "ac", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
              end, { desc = "class [Treesitter]" })

              vim.keymap.set({ "x", "o" }, "ic", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
              end, { desc = "class [Treesitter]" })

              -- p: parameter
              vim.keymap.set({ "x", "o" }, "ap", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
              end, { desc = "parameter [Treesitter]" })

              vim.keymap.set({ "x", "o" }, "ip", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
              end, { desc = "parameter [Treesitter]" })

              -- l: loop
              vim.keymap.set({ "x", "o" }, "al", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@loop.outer", "textobjects")
              end, { desc = "loop [Treesitter]" })

              vim.keymap.set({ "x", "o" }, "il", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@loop.inner", "textobjects")
              end, { desc = "loop [Treesitter]" })

              -- c: conditional
              vim.keymap.set({ "x", "o" }, "ac", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@conditional.outer", "textobjects")
              end, { desc = "conditional [Treesitter]" })

              vim.keymap.set({ "x", "o" }, "ic", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@conditional.inner", "textobjects")
              end, { desc = "conditional [Treesitter]" })

              -- s: scope
              vim.keymap.set({ "x", "o" }, "as", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
              end, { desc = "scope [Treesitter]" })
            '';
          };

          # Move based on indentation
          vim-indentwise = {
            package = vim-indentwise;
          };
        };
      };
    };
  };
}
