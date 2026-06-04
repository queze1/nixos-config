{
  # TODO: Wrap with wrapper module
  flake.homeModules.btop = {
    programs.btop = {
      enable = true;
      settings = {
        theme_background = false;
      };
    };
  };
}
