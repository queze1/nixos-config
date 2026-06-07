{
  flake.homeModules.nvf = {
    programs.nvf.settings.vim = {
      lsp = {
        lspsaga = {
          enable = true;
          setupOpts = {
            lightbulb.enable = false;
          };
        };
        # Overwrite with Lspsaga
        mappings = {
          hover = null;
          codeAction = null;
        };
      };

      keymaps = [
        {
          key = "<leader>lh";
          mode = "n";
          action = ":Lspsaga hover_doc<CR>";
          silent = true;
          desc = "Lspsaga: Hover";
        }
        {
          key = "K";
          mode = "n";
          action = ":Lspsaga hover_doc<CR>";
          silent = true;
          desc = "Lspsaga: Hover";
        }
        {
          key = "<leader>la";
          mode = "n";
          action = ":Lspsaga code_action<CR>";
          silent = true;
          desc = "Lspsaga: Code Action";
        }
        {
          key = "<leader>ld";
          mode = "n";
          action = ":Lspsaga peek_definition<CR>";
          silent = true;
          desc = "Lspsaga: Peek Definition";
        }
        {
          key = "gO";
          mode = "n";
          action = ":Lspsaga outline<CR>";
          silent = true;
          desc = "Lspsaga: Outline";
        }
      ];
    };
  };
}
