{
  flake.homeModules.nvf = {pkgs, ...}: {
    home.packages = [
      pkgs.luaPackages.tree-sitter-cli
    ];

    programs.nvf.settings.vim = {
      treesitter = {
        enable = true;
        context.enable = true;
        fold = true;
      };

      extraPlugins = with pkgs.vimPlugins; {
        # Needed as treesitter.textobjects is broken
        nvim-treesitter-textobjects = {
          package = nvim-treesitter-textobjects;
          setup = ''
            require("nvim-treesitter-textobjects").setup({
              select = {
                enable = true,
                -- Automatically jump forward to textobj, similar to targets.vim
                lookahead = true,

                selection_modes = {
                  ['@parameter.outer'] = 'v', -- charwise
                  ['@function.outer'] = 'V', -- linewise
                },

                -- If you set this to `true` (default is `false`) then any textobject is
                -- extended to include preceding or succeeding whitespace.
                include_surrounding_whitespace = false,
              },
            })

            -- f: function
            vim.keymap.set({ "x", "o" }, "af", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
            end, { desc = "function [Treesitter]" })

            vim.keymap.set({ "x", "o" }, "if", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
            end, { desc = "function [Treesitter]" })

            -- c: class
            vim.keymap.set({ "x", "o" }, "ac", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
            end, { desc = "class [Treesitter]" })

            vim.keymap.set({ "x", "o" }, "ic", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
            end, { desc = "class [Treesitter]" })

            -- m: method
            vim.keymap.set({ "x", "o" }, "am", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
            end, { desc = "method [Treesitter]" })

            vim.keymap.set({ "x", "o" }, "im", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
            end, { desc = "method [Treesitter]" })

            -- l: loop
            vim.keymap.set({ "x", "o" }, "al", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@loop.outer", "textobjects")
            end, { desc = "loop [Treesitter]" })

            vim.keymap.set({ "x", "o" }, "il", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@loop.inner", "textobjects")
            end, { desc = "loop [Treesitter]" })

            -- c: conditional
            vim.keymap.set({ "x", "o" }, "ac", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@conditional.outer", "textobjects")
            end, { desc = "conditional [Treesitter]" })

            vim.keymap.set({ "x", "o" }, "ic", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@conditional.inner", "textobjects")
            end, { desc = "conditional [Treesitter]" })

            -- s: scope
            vim.keymap.set({ "x", "o" }, "as", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
            end, { desc = "scope [Treesitter]" })
          '';
        };
      };
    };
  };
}
