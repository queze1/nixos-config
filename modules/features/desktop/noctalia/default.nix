{
  inputs,
  ...
}:
{
  flake.homeModules.noctalia =
    { config, self, ... }:
    let
      settings = builtins.fromJSON (builtins.readFile ./settings.json);

      # TODO: Swap to XDG pictures
      modifiedSettings = settings // {
        wallpaper = {
          directory = "/mnt/utm/Pictures/Wallpapers";
        };
      };
    in
    {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      programs.noctalia-shell = {
        enable = true;
        settings = modifiedSettings;
      };

      home.shellAliases = {
        # TODO: Get the directory of this file and then put the result in that directory
        noctalia-export = "noctalia-shell ipc call state all | nix run nixpkgs#jq .settings > ~/etc/nixos/home/modules/desktop/noctalia.json";
      };

      home.file.profilePicture = {
        target = "${config.home.homeDirectory}/.face";
        source = "${self}/assets/pfp.png";
      };

      home.file.".cache/noctalia/wallpapers.json" = {
        text = builtins.toJSON {
          defaultWallpaper = "${self}/assets/laine-chinensy-temptation-v6.png";
        };
      };
    };
}
