{
  flake.homeModules.vesktop = {
    programs.vesktop = {
      enable = true;
      # TODO: Add themes from GitHub repo and delete GitHub repo
      vencord = {
        settings = builtins.fromJSON (builtins.readFile ./settings.json);
      };
    };
  };
}
