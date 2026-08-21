{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.programs.nvf.enable {
    home-manager.sharedModules = [
      ({lib, ...}: {
        # Preserve copilot.nvim token
        my.home.preservation.extraDirectories = [
          ".config/github-copilot"
        ];

        programs.nvf.settings.vim = {
          # LLM integration
          assistant = {
            copilot = {
              enable = false;
              setupOpts = {
                suggestion.enabled = false;
              };
            };
            codecompanion-nvim = {
              enable = true;
              setupOpts = {
                interactions = {
                  chat = {
                    adapter = {
                      name = "copilot";
                    };
                  };
                  inline = {
                    adapter = "copilot";
                  };
                  cli = {
                    agent = "codex";
                    agents = {
                      codex = {
                        cmd = "codex";
                        args = {};
                        description = "OpenAI Codex CLI";
                      };
                      copilot = {
                        cmd = "copilot";
                        args = {};
                        description = "Copilot CLI";
                      };
                      cursor = {
                        cmd = "cursor";
                        args = {};
                        description = "Cursor CLI";
                      };
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
