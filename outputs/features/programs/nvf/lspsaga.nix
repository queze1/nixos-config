{
  flake.homeModules.nvf = {
    programs.nvf.settings.vim = {
      lsp = {
        lspsaga = {
          enable = true;
          setupOpts = {
            lightbulb.enable = false;
            symbol_in_winbar.enable = false;
            definition = {
              keys = {
                # Always use 'o' for editing
                edit = "o";
              };
            };
          };
        };
        # Overwrite with Lspsaga
        mappings = {
          format = null;
          hover = null;
          codeAction = null;
          renameSymbol = null;
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
          key = "<leader>ln";
          mode = "n";
          action = ":Lspsaga rename<CR>";
          silent = true;
          desc = "Lspsaga: Rename";
        }
        {
          key = "<leader>lci";
          mode = "n";
          action = ":Lspsaga incoming_calls<CR>";
          silent = true;
          desc = "Lspsaga: Incoming Calls";
        }
        {
          key = "<leader>lco";
          mode = "n";
          action = ":Lspsaga outgoing_calls<CR>";
          silent = true;
          desc = "Lspsaga: Outgoing Calls";
        }
        {
          key = "gO";
          mode = "n";
          action = ":Lspsaga outline<CR>";
          silent = true;
          desc = "Lspsaga: Outline";
        }
        {
          key = "<leader>lO";
          mode = "n";
          action = ":Lspsaga outline<CR>";
          silent = true;
          desc = "Lspsaga: Outline";
        }
        {
          key = "<leader>lf";
          mode = "n";
          action = ":Lspsaga finder<CR>";
          silent = true;
          desc = "Lspsaga: Finder";
        }
      ];
    };
  };
}
