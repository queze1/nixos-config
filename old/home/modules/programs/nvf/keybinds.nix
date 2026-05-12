{ lib, ... }:
{
  programs.nvf.settings.vim = {
    # ----------------------------------------
    # Autocommands
    # ----------------------------------------
    augroups = [
      {
        name = "close_with_q";
        clear = true;
      }
    ];

    # Close special buffers with 'q'
    autocmds = [
      {
        event = [ "FileType" ];
        group = "close_with_q";
        pattern = [
          # Use :set ft? to find FileType
          "checkhealth"
          "help"
          "lspinfo"
          "man"
          "qf"
        ];
        callback = lib.generators.mkLuaInline ''
          function(event)
            vim.keymap.set("n", "q", "<cmd>close<cr>", { 
              buffer = event.buf, 
              silent = true,
              desc = "Close special buffer" 
            })
          end
        '';
      }
      # Reload LSPs after loading direnv
      {
        event = [ "User" ];
        pattern = [
          "DirenvLoaded"
        ];
        callback = lib.generators.mkLuaInline ''
          function()
            local cwd = vim.fn.getcwd()
            
            -- Skip if we have already restarted the LSP for this directory
            if vim.g.last_direnv_path == cwd then
              return
            end

            local clients = vim.lsp.get_clients({ bufnr = 0 })
            if #clients > 0 then
              vim.cmd("lsp restart")
              vim.g.last_direnv_path = cwd
            end
          end
        '';
      }
    ];

    # ----------------------------------------
    # Keymaps
    # ----------------------------------------
    keymaps = [
      # Ctrl-S to save
      {
        key = "<C-s>";
        mode = [
          "n"
          "i"
          "v"
        ];
        action = "<Cmd>w<CR>";
        silent = true;
        desc = "Save file";
      }
      # H to go to start (^), L to go to end ($)
      {
        key = "H";
        mode = [
          "n"
          "v"
          "o"
        ];
        action = "^";
        silent = true;
        desc = "Go to start of line";
      }
      {
        key = "L";
        mode = [
          "n"
          "v"
          "o"
        ];
        action = "$";
        silent = true;
        desc = "Go to end of line";
      }
      # Window navigation
      {
        key = "<C-h>";
        mode = "n";
        action = "<C-w>h";
        silent = true;
        desc = "Move to window left";
      }
      {
        key = "<C-j>";
        mode = "n";
        action = "<C-w>j";
        silent = true;
        desc = "Move to window down";
      }
      {
        key = "<C-k>";
        mode = "n";
        action = "<C-w>k";
        silent = true;
        desc = "Move to window up";
      }
      {
        key = "<C-l>";
        mode = "n";
        action = "<C-w>l";
        silent = true;
        desc = "Move to window right";
      }
      # Clear search highlights with ESC
      {
        key = "<Esc>";
        mode = "n";
        action = "<Cmd>nohlsearch<CR>";
        silent = true;
        desc = "Clear search highlights";
      }
      # CodeCompanion keybinds
      {
        key = "<C-a>";
        mode = [
          "n"
          "v"
        ];
        action = "<cmd>CodeCompanionActions<cr>";
        silent = true;
        desc = "Open CodeCompanion actions";
      }
      {
        key = "<Leader>a";
        mode = [
          "n"
          "v"
        ];
        action = "<cmd>CodeCompanionChat Toggle<cr>";
        silent = true;
        desc = "Toggle CodeCompanion Chat";
      }
      {
        key = "ga";
        mode = [ "v" ];
        action = "<cmd>CodeCompanionChat Add<cr>";
        silent = true;
        desc = "Add selected text to CodeCompanion Chat";
      }
      {
        key = "cc";
        mode = "ca";
        action = "CodeCompanion";
        silent = true;
      }
    ];

    # ----------------------------------------
    # WhichKey
    # ----------------------------------------
    binds.whichKey = {
      enable = true;
      register = {
        # Workaround for bugged Harpoon WhichKey
        "<leader>a" = lib.mkForce "Toggle CodeCompanion Chat";
        "<leader>m" = "Mark file [Harpoon]";
      };
    };

    luaConfigRC.whichkey-visual = ''
      local wk = require("which-key")
      wk.add({
        { "*", mode = "v", desc = "Search selection forward" },
        { "#", mode = "v", desc = "Search selection backward" },
        { "@", mode = "v", desc = "Run macro on selection" },
        { "Q", mode = "v", desc = "Repeat last macro on selection" },
        { ";", mode = "v", desc = "Repeat char jump (forward)" },
        { ",", mode = "v", desc = "Repeat char jump (backward)" },
      })
    '';
  };
}
