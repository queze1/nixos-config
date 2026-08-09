{
  flake.homeModules.llmTools = {pkgs, ...}: {
    home.packages = with pkgs; [
      cursor-cli
      codex
      github-copilot-cli
    ];

    my.home.preservation.extraDirectories = [
      ".codex"
      ".copilot"
    ];
  };
}
