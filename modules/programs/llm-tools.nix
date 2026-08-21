{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.llmTools;
in {
  options.my.programs.llmTools.enable = lib.mkEnableOption "LLM tools" // {default = config.my.programs.enableAll;};

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = with pkgs; [
          codex
          github-copilot-cli
          mcp-nixos
        ];

        my.home.preservation.extraDirectories = [
          ".codex"
          ".copilot"
        ];
      })
    ];
  };
}
