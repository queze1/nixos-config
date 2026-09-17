{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.programs.nvf.enable {
    home-manager.sharedModules = [
      ({pkgs, ...}: {
        programs.nvf.settings.vim = {
          languages = {
            clang.enable = true;
            go.enable = true;
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

          debugger.nvim-dap = {
            enable = true;
            ui.enable = true;
          };

          formatter.conform-nvim.setupOpts.formatters_by_ft = {
            # Uses ruff in PATH
            python = [
              "ruff_fix"
              "ruff_format"
              "ruff_organize_imports"
            ];
          };

          extraPlugins = {
            # Markdown rendering & editing
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
