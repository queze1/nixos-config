{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.programs.nvf;
  github-actions-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "github-actions-nvim";
    src = inputs.github-actions-nvim;
  };
in {
  options.my.programs.nvf.enable = lib.mkEnableOption "NVF";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({
        lib,
        pkgs,
        ...
      }: {
        imports = [
          inputs.nvf.homeManagerModules.default
        ];

        my.home.preservation.extraDirectories = [
          ".local/state/nvf" # preserve nvim state
          ".local/share/nvf" # preserve nvim plugin state
          ".local/state/lazygit" # stop showing welcome message
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
            visuals.indent-blankline.enable = true;
            binds.whichKey.enable = true;

            # ----------------------------------------
            # Editing
            # ----------------------------------------
            autocomplete.nvim-cmp.enable = true;
            utility.surround.enable = true;
            autopairs.nvim-autopairs.enable = true;

            # Format on save
            formatter.conform-nvim.enable = true;

            # Paste images from system clipboard
            utility.images.img-clip.enable = true;

            # ----------------------------------------
            # Navigation
            # ----------------------------------------
            # Search case-insensitive unless a capital letter is used
            searchCase = "smart";

            # Jumping
            utility.motion.flash-nvim.enable = true;

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

            # Punish spamming the same key
            binds.hardtime-nvim = {
              enable = true;
              setupOpts = {
                disable_mouse = false;
                disabled_filetypes = {
                  "sagafinder" = true;
                  "saga_finder" = true;
                };
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

            # Direnv integration
            utility.direnv.enable = true;

            # ----------------------------------------
            # Extra Plugins
            # ----------------------------------------
            extraPlugins = {
              auto-save = {
                package = pkgs.vimPlugins.auto-save-nvim;
                setup = ''
                  local autosave = require("auto-save")
                  autosave.setup({})
                '';
              };

              # Autocomplete for command line
              cmp-cmdline = {
                package = pkgs.vimPlugins.cmp-cmdline;
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
                package = pkgs.vimPlugins.neoscroll-nvim;
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

              # Detect outdated GHA actions & run workflows
              github-actions-nvim = {
                package = github-actions-nvim;
                setup = ''
                  local actions = require('github-actions')
                  vim.keymap.set('n', '<leader>gd', actions.dispatch_workflow, { desc = 'Dispatch workflow' })
                  vim.keymap.set('n', '<leader>gh', actions.show_history, { desc = 'Show workflow history' })
                  vim.keymap.set('n', '<leader>gp', function() actions.show_history({ pr_mode = true }) end, { desc = 'Show workflow history by branch/PR' })
                  vim.keymap.set('n', '<leader>gw', actions.watch_workflow, { desc = 'Watch running workflow' })
                  vim.keymap.set('n', '<leader>go', actions.open_workflow_url, { desc = 'Open workflow URL in browser' })
                  actions.setup({});
                '';
              };
            };
          };
        };
      })
    ];
  };
}
