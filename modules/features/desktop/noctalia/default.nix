{
  inputs,
  ...
}:
{
  flake.homeModules.noctalia =
    { config, ... }:
    let
      settings = builtins.fromJSON (builtins.readFile ./settings.json);

      # TODO: Swap to XDG pictures
      modifiedSettings = settings // {
        wallpaper = {
          directory = "/mnt/utm/Pictures/Wallpapers";
          monitorDirectories = [
            {
              directory = "/home/queze/Pictures/Wallpapers";
              name = "Virtual-1";
              wallpaper = "";
            }
          ];
        };
      };
    in
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
        # TODO: Use Home Manager to add default profile picture & wallpaper
        settings = modifiedSettings;
      };
    };
}
