{
  flake.homeModules.vscode = {
    programs.vscode = {
      enable = true;
    };

    my.home.preservation.extraDirectories = [
      ".vscode"
      ".vscode-shared"
      ".config/Code"
    ];
  };
}
