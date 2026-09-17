{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.programs.nvf.enable {
    home-manager.sharedModules = [
      ({
        lib,
        pkgs,
        ...
      }: {
        programs.nvf.settings.vim.lsp.servers.basedpyright = {
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
      })
    ];
  };
}
