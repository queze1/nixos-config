{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.my.programs.nvf.enable {
    home-manager.sharedModules = [
      ({lib, ...}: {
        programs.nvf.settings.vim = {
          # LLM integration
          assistant.codecompanion-nvim = {
            enable = true;
            setupOpts = {
              interactions = {
                cli = {
                  agent = "codex";
                  agents = {
                    codex = {
                      cmd = lib.getExe pkgs.codex;
                      args = {};
                      description = "OpenAI Codex CLI";
                    };
                  };
                };
              };
            };
          };

          # CodeCompanion keybinds
          keymaps = [
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
              action = "<cmd>CodeCompanionCLI<cr>";
              silent = true;
              desc = "Open CodeCompanion CLI";
            }
            {
              key = "ga";
              mode = "v";
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

          binds.whichKey = {
            enable = true;
            register = {
              # Workaround for bugged Harpoon WhichKey
              "<leader>a" = lib.mkForce "Toggle CodeCompanion Chat";
            };
          };
        };
      })
    ];
  };
}
