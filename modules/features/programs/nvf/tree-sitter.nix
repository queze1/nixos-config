{
  flake.homeModules.nvf = {pkgs, ...}: {
    home.packages = [pkgs.luaPackages.tree-sitter-cli];

    programs.nvf.settings.vim = {
      treesitter = {
        enable = true;
        context.enable = true;
        fold = true;
        grammars = with pkgs.vimPlugins.nvim-treesitter-parsers; [
          cpp
          kdl
          nix
        ];
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

            -- SELECTION --

            -- f: function
            vim.keymap.set({ "x", "o" }, "af", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
            end, { desc = "function [Treesitter]" })
            vim.keymap.set({ "x", "o" }, "if", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
            end, { desc = "function [Treesitter]" })

            -- c: call
            vim.keymap.set({ "x", "o" }, "ac", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@call.outer", "textobjects")
            end, { desc = "call [Treesitter]" })
            vim.keymap.set({ "x", "o" }, "ic", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@call.inner", "textobjects")
            end, { desc = "call [Treesitter]" })

            -- C: class
            vim.keymap.set({ "x", "o" }, "aC", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
            end, { desc = "class [Treesitter]" })
            vim.keymap.set({ "x", "o" }, "iC", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
            end, { desc = "class [Treesitter]" })

            -- a: parameter (a for 'argument')
            vim.keymap.set({ "x", "o" }, "aa", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
            end, { desc = "parameter [Treesitter]" })
            vim.keymap.set({ "x", "o" }, "ia", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
            end, { desc = "parameter [Treesitter]" })

            -- l: loop
            vim.keymap.set({ "x", "o" }, "al", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@loop.outer", "textobjects")
            end, { desc = "loop [Treesitter]" })
            vim.keymap.set({ "x", "o" }, "il", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@loop.inner", "textobjects")
            end, { desc = "loop [Treesitter]" })

            -- o: conditional (o for 'or')
            vim.keymap.set({ "x", "o" }, "ao", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@conditional.outer", "textobjects")
            end, { desc = "conditional [Treesitter]" })
            vim.keymap.set({ "x", "o" }, "io", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@conditional.inner", "textobjects")
            end, { desc = "conditional [Treesitter]" })

            -- =: assignment
            vim.keymap.set({ "x", "o" }, "a=", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@assignment.outer", "textobjects")
            end, { desc = "assignment [Treesitter]" })
            vim.keymap.set({ "x", "o" }, "i=", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@assignment.inner", "textobjects")
            end, { desc = "assignment [Treesitter]" })
            vim.keymap.set({ "x", "o" }, "l=", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@assignment.lhs", "textobjects")
            end, { desc = "assignment LHS [Treesitter]" })
            vim.keymap.set({ "x", "o" }, "r=", function()
              require("nvim-treesitter-textobjects.select").select_textobject("@assignment.rhs", "textobjects")
            end, { desc = "assignment RHS [Treesitter]" })

            -- MOVEMENT --
            vim.keymap.set({ "n", "x", "o" }, "]a", function()
              require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.inner", "textobjects")
            end, { desc = "next parameter [Treesitter]" })
            vim.keymap.set({ "n", "x", "o" }, "[a", function()
              require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.inner", "textobjects")
            end, { desc = "previous parameter [Treesitter]" })
          '';
        };
      };
    };
  };
}
