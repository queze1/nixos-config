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
          textobjects = {
            enable = true;
            setupOpts = {
              select = {
                enable = true;
                # Automatically jump forward to the next text object
                lookahead = true;
                keymaps = {
                  # f: function
                  "af" = "@function.outer";
                  "if" = "@function.inner";

                  # c: class
                  "ac" = "@class.outer";
                  "ic" = "@class.inner";

                  # a: argument
                  "aa" = "@parameter.outer";
                  "ia" = "@parameter.inner";

                  # a: loop
                  "al" = "@loop.outer";
                  "il" = "@loop.inner";

                  # i: if-statement
                  "ai" = "@conditional.outer";
                  "ii" = "@conditional.inner";
                };
              };

              move = {
                enable = true;
                set_jumps = true;
                goto_next_start = {
                  "]f" = "@function.outer";
                  "]c" = "@class.outer";
                };
                goto_previous_start = {
                  "[f" = "@function.outer";
                  "[c" = "@class.outer";
                };
              };
            };
          };

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
      };
    };
  };
}
