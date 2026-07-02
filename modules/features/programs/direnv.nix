{
  flake.homeModules.direnv = {
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };

    my.home.preservation.extraDirectories = [
      ".local/share/direnv"
    ];
  };
}
