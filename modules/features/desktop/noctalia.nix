{
  config,
  inputs,
  lib,
  ...
}: {
  config = lib.mkIf config.my.desktop.enable {
    home-manager.sharedModules = [
      ({config, ...}: let
        settings = builtins.fromJSON (builtins.readFile ./noctalia/settings.json);
        modifiedSettings =
          settings
          // {
            wallpaper = {
              directory = "${config.xdg.userDirs.pictures}/Wallpapers";
            };
          };
      in {
        imports = [inputs.noctalia.homeModules.default];

        programs.noctalia-shell = {
          enable = true;
          settings = modifiedSettings;
        };

        home.shellAliases = {
          noctalia-export = "noctalia-shell ipc call state all | nix run nixpkgs#jq .settings > ~/etc/nixos/modules/features/desktop/noctalia/noctalia.json";
        };

        home.file.profilePicture = {
          target = "${config.home.homeDirectory}/.face";
          # Use relative path instead of ${self} for performance
          source = ../../../assets/pfp.png;
        };

        home.file.".cache/noctalia/wallpapers.json" = {
          text = builtins.toJSON {
            defaultWallpaper = ../../../assets/laine-chinensy-temptation-v6.png;
          };
        };

        # Stop showing welcome message
        my.home.preservation.extraDirectories = [
          ".cache/noctalia"
        ];
      })
    ];
  };
}
