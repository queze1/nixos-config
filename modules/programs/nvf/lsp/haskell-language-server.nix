{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.programs.nvf.enable {
    home-manager.sharedModules = [
      ({lib, ...}: {
        programs.nvf.settings.vim.lsp.servers.haskell-language-server = {
          # Force to use PATH
          cmd = lib.mkForce [
            "haskell-language-server-wrapper"
            "--lsp"
          ];
        };
      })
    ];
  };
}
