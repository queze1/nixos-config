{
  inputs,
  ...
}:
{
  flake.homeModules.noctalia =
    { config, ... }:
    {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      home.shellAliases = {
        # TODO: Get the directory of this file and then put the result in that directory
        noctalia-export = "noctalia-shell ipc call state all | nix run nixpkgs#jq .settings > ~/etc/nixos/home/modules/desktop/noctalia.json";
      };

      home.file.profilePicture = {
        target = "${config.home.homeDirectory}/.face";
      };

      programs.noctalia-shell = {
        enable = true;
        # TODO: Use Home Manager to set default profile picture & wallpaper
        settings = builtins.fromJSON (builtins.readFile ./noctalia.json);
      };
    };
}
