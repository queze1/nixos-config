{
  flake.factory.devenv = {username}: {pkgs, ...}: {
    # Required for devenv
    nix.settings = {
      trusted-users = ["${username}"];
    };

    home-manager.users.${username} = {
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
  };
}
