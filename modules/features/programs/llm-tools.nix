{
  flake.homeModules.llmTools = {pkgs, ...}: {
    home.packages = with pkgs; [
      codex
      github-copilot-cli
      mcp-nixos
    ];

    my.home.preservation.extraDirectories = [
      ".codex"
      ".copilot"
    ];
  };
}
