{
  config,
  lib,
  ...
}: let
  cfg = config.my.editor.vim;
in {
  options.my.editor.vim.enable = lib.mkEnableOption "Vim as the default editor";

  config = lib.mkIf cfg.enable {
    environment.variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };
}
