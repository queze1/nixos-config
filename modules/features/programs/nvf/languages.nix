{
  flake.homeModules.nvf = {
    lib,
    pkgs,
    osConfig,
    ...
  }: let
    inherit (lib.generators) mkLuaInline;
    hostName = osConfig.networking.hostName;
  in {
    programs.nvf.settings.vim = {
      languages = {
        java.enable = true;
        markdown = {
          enable = true;
          extensions.render-markdown-nvim.enable = true;
        };
        nix = {
          enable = true;
          lsp.servers = ["nixd"];
        };
        python = {
          enable = true;
          # We manually configure Python formatting elsewhere
          format.enable = false;
        };
        rust.enable = true;
        typescript.enable = true;
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

          nixd = {
            settings = {
              nixd = {
                nixpkgs = {
                  expr = "(builtins.getFlake (builtins.toString ./.)).inputs.nixpkgs";
                };
                formatting = {
                  command = ["${lib.getExe pkgs.alejandra}"];
                };
                options = {
                  nixos = {
                    expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.${hostName}.options";
                  };
                  home_manager = {
                    expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.${hostName}.options.home-manager.users.type.getSubOptions []";
                  };
                  flake_parts = {
                    expr = "(builtins.getFlake (builtins.toString ./.)).debug.options";
                  };
                  flake_parts2 = {
                    expr = "(builtins.getFlake (builtins.toString ./.)).currentSystem.options";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
