{
  flake.homeModules.nvf = {
    config,
    lib,
    osConfig,
    pkgs,
    ...
  }: let
    hostName = osConfig.networking.hostName;
    flakePath = "${config.home.homeDirectory}/etc/nixos";
    dafny-nvim = pkgs.vimUtils.buildVimPlugin {
      name = "dafny-nvim";
      src = pkgs.fetchFromGitHub {
        owner = "CameronBadman";
        repo = "dafny-nvim";
        rev = "94e5b204ff2312f96207ee259f54f787a68733b1";
        hash = "sha256-e/ndm/AURRZSGUL/slAkzri2XNcmCpz8fzQVI5ScXFI=";
      };
    };
  in {
    home.packages = [pkgs.dafny];

    programs.nvf.settings.vim = {
      languages = {
        clang.enable = true;
        java.enable = true;
        markdown = {
          enable = true;
          extensions.render-markdown-nvim.enable = true;
        };
        make = {
          enable = true;
          format.enable = true;
          extraDiagnostics.enable = true;
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
        sources = {
          # Hack for assignment
          os161-debugger = ''
            dap.adapters.cppdbg = {
              type = 'executable',
              id = 'cppdbg',
              command = '${pkgs.vscode-extensions.ms-vscode.cpptools}/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7',
            }

            dap.configurations.cpp = {
              {
                name = 'OS161 Debug',
                type = 'cppdbg',
                request = 'launch',
                program = vim.env.HOME .. '/cs3231/root/kernel',
                args = {},
                stopAtEntry = false,
                cwd = vim.env.HOME .. '/cs3231/root',
                environment = {},
                externalConsole = false,
                MIMode = 'gdb',
                miDebuggerServerAddress = 'unix:.sockets/gdb',
                miDebuggerPath = '/nix/store/j7hn67w0n3v13ifzys24qmszxm432cwk-os161-gdb-7.8/bin/os161-gdb',
                setupCommands = {
                  {
                    description = 'Enable pretty-printing for gdb',
                    text = '-enable-pretty-printing',
                    ignoreFailures = true,
                  },
                },
              },
            }

            dap.configurations.c = dap.configurations.cpp
          '';
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
            # Hack for assignment
            clangd.on_attach = lib.mkLuaInline "function(c) c.server_capabilities.documentFormattingProvider = false end";
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

          dafny = {
            cmd = [
              "${pkgs.dafny}/bin/dafny"
              "server"
              "--solver-path"
              "${pkgs.z3}/bin/z3"
            ];
            filetypes = ["dfy" "dafny"];
            root_markers = [".git"];
          };

          nixd = {
            settings = {
              nixd = {
                nixpkgs = {
                  expr = "(builtins.getFlake \"${flakePath}\").inputs.nixpkgs";
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
        vim-loves-dafny = {
          package = pkgs.vimPlugins.vim-loves-dafny;
          setup = '''';
        };
        dafny-nvim = {
          package = dafny-nvim;
          setup = ''
            require("dafny").setup({
              counter_example_depth = 5,    -- depth passed to dafny/counterExample request
              counter_debounce_ms   = 1000, -- ms to wait after last symbolStatus before fetching counter examples
            })
          '';
        };
      };
    };
  };
}
