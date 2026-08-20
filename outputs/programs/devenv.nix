{
  flake.homeModules.devenv = {pkgs, ...}: {
    home.packages = [pkgs.devenv];

    # Preserve devenv allow
    my.home.preservation.extraDirectories = [
      ".local/share/devenv"
    ];

    # Automatically enter devenv shell with Fish
    programs.fish.interactiveShellInit = ''
      devenv hook fish | source
    '';
  };
}
