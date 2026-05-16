{
  inputs,
  ...
}:
{
  flake.homeModules.noctalia = {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia-shell = {
      enable = true;
      # TODO: Selectively override settings which should be dynamic
      # TODO: Use Home Manager to set default profile picture & wallpaper
      settings = builtins.fromJSON (builtins.readFile ./noctalia.json);
    };
  };
}
