{
  flake.homeModules.nvf = {
    osConfig,
    lib,
    ...
  }: {
    my.home.preservation.extraDirectories = [
      ".config/github-copilot" # preserve copilot.nvim token
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
          enable = false;
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
                agent = "copilot";
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
            adapters = lib.mkLuaInline ''
              {
                ["http"]= {
                  ["tavily"] = function()
                    return require("codecompanion.adapters").extend("tavily", {
                      env = {
                        api_key = "cmd:cat ${osConfig.age.secrets.tavily-api-key.path}",
                      },
                    })
                  end,
                },
              }
            '';
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
          action = "<cmd>CodeCompanionChat Toggle<cr>";
          silent = true;
          desc = "Toggle CodeCompanion Chat";
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
  };
}
