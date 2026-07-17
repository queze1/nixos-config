{
  flake.homeModules.vscode = {pkgs, ...}: {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode.fhsWithPackages (
        ps:
          with ps; [
            dotnetCorePackages.dotnet_10.runtime
          ]
      );
    };

    my.home.preservation.extraDirectories = [
      ".vscode"
      ".vscode-shared"
      ".config/Code"
    ];
  };
}
