{
  config,
  self,
  lib,
  ...
}: {
  config = lib.mkIf config.my.programs.nvf.enable {
    home-manager.sharedModules = [
      ({
        config,
        lib,
        osConfig,
        pkgs,
        ...
      }: let
        hostName = osConfig.networking.hostName;
        flakePath = "${config.home.homeDirectory}/etc/nixos";
      in {
        home.packages = [
          self.packages.${pkgs.stdenv.hostPlatform.system}.actions-languageserver
        ];

        programs.nvf.settings.vim = {
          languages = {
            clang.enable = true;
            go.enable = true;
            markdown = {
              enable = true;
              extensions.render-markdown-nvim.enable = true;
            };
            yaml = {
              enable = true;
              lsp.enable = false;
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

          debugger.nvim-dap = {
            enable = true;
            ui.enable = true;
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
              actionsls = {
                cmd = ["actions-languageserver" "--stdio"];
                filetypes = ["yaml"];
                root_markers = [".github/workflows"];
                capabilities = {
                  workspace = {
                    didChangeWorkspaceFolders = {
                      dynamicRegistration = true;
                    };
                  };
                };
              };

              basedpyright = {
                settings = {
                  basedpyright = {
                    disableOrganizeImports = true;
                  };
                };
                # Replace commands created by nvf
                # LspPyrightOrganizeImports: made redundant by ruff
                # LspPyrightSetPythonPath: made redundant by direnv
                on_attach = lib.mkForce (lib.mkLuaInline ''
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
                      expr = "import (builtins.getFlake \"${flakePath}\").inputs.nixpkgs {}";
                    };
                    formatting = {
                      command = ["${lib.getExe pkgs.alejandra}"];
                    };
                    options = {
                      nixos = {
                        expr = "(builtins.getFlake \"${flakePath}\").nixosConfigurations.${hostName}.options";
                      };
                      home_manager = {
                        expr = "(builtins.getFlake \"${flakePath}\").nixosConfigurations.${hostName}.options.home-manager.users.type.getSubOptions []";
                      };
                      flake_parts = {
                        expr = "(builtins.getFlake \"${flakePath}\").debug.options";
                      };
                      flake_parts2 = {
                        expr = "(builtins.getFlake \"${flakePath}\").currentSystem.options";
                      };
                    };
                  };
                };
              };
            };
          };

          extraPlugins = {
            markdown-nvim = {
              package = pkgs.vimPlugins.markdown-nvim;
              setup = ''
                require("markdown").setup({})
              '';
            };
          };
        };
      })
    ];
  };
}
