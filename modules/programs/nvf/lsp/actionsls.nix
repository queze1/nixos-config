{
  config,
  lib,
  self,
  ...
}: {
  config = lib.mkIf config.my.programs.nvf.enable {
    home-manager.sharedModules = [
      ({pkgs, ...}: let
        actions-languageserver = self.packages.${pkgs.stdenv.hostPlatform.system}.actions-languageserver;
      in {
        programs.nvf.settings.vim.lsp.servers.actionsls = {
          # From https://github.com/actions/languageservices/tree/main/languageserver
          cmd = [
            (lib.getExe actions-languageserver)
            "--stdio"
          ];
          filetypes = ["yaml"];
          root_markers = [
            ".github/workflows"
            ".forgejo/workflows"
            ".gitea/workflows"
          ];
          capabilities = {
            workspace = {
              didChangeWorkspaceFolders = {
                dynamicRegistration = true;
              };
            };
          };
        };
      })
    ];
  };
}
