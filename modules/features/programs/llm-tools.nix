{
  flake.homeModules.llmTools = {pkgs, ...}: {
    home.packages = with pkgs; [
      codex
      github-copilot-cli
    ];

    my.home.preservation.extraDirectories = [
      ".codex"
      ".copilot"
    ];
  };
}
