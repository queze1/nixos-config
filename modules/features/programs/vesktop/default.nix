{self, ...}: let
  # Dynamically find themes in assets/themes
  themesDir = "${self}/assets/themes";
  themeDirContents = builtins.readDir themesDir;

  themeNames =
    builtins.filter
    (name: themeDirContents.${name} == "regular")
    (builtins.attrNames themeDirContents);

  themeSet = builtins.listToAttrs (map (name: {
      name = name;
      value = builtins.readFile "${themesDir}/${name}";
    })
    themeNames);
in {
  flake.homeModules.vesktop = {
    programs.vesktop = {
      enable = true;
      vencord = {
        settings = builtins.fromJSON (builtins.readFile ./settings.json);
        themes = themeSet;
      };
    };
  };
}
