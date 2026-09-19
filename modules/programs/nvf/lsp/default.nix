{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.programs.nvf.enable {
    home-manager.sharedModules = [
      {
        programs.nvf.settings.vim.lsp = {
          enable = true;
          formatOnSave = true;
        };
      }
    ];
  };
}
