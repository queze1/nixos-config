{inputs, ...}: {
  flake.homeModules.nvf = {
    osConfig,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      inputs.nvf.homeManagerModules.default
    ];

    programs.nvf = {
      enable = true;
      settings.vim = {
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

        # Make LSP look nicer
        lsp.lspsaga = {
          enable = true;
        };

        treesitter = {
          enable = true;
          context.enable = true;
          fold = true;
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
          copilot = {
            enable = true;
            setupOpts = {
              suggestion.enabled = false;
            };
          };
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
                cli = {
                  agent = "copilot";
                  agents = {
                    codex = {
                      cmd = "codex";
                      args = {};
                      description = "OpenAI Codex CLI";
                    };
                    copilot = {
                      cmd = "copilot";
                      args = {};
                      description = "Copilot CLI";
                    };
                    cursor = {
                      cmd = "cursor";
                      args = {};
                      description = "Cursor CLI";
                    };
                  };
                };
              };
              adapters = lib.mkLuaInline ''
                {
                  ["http"]= {
                    ["tavily"] = function()
                      return require("codecompanion.adapters").extend("tavily", {
                        env = {
                          api_key = "cmd:cat ${osConfig.age.secrets.tavily-api-key.path}",
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

              -- m: method
              vim.keymap.set({ "x", "o" }, "am", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
              end, { desc = "method [Treesitter]" })

              vim.keymap.set({ "x", "o" }, "im", function()
                require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
              end, { desc = "method [Treesitter]" })

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
