{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.my.desktop.noctalia;
in {
  options.my.desktop.noctalia.enable = lib.mkEnableOption "Noctalia";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({config, ...}: let
        settings = builtins.fromJSON (builtins.readFile ./settings.json);
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
          noctalia-export = "noctalia-shell ipc call state all | nix run nixpkgs#jq .settings > ~/etc/nixos/modules/desktop/noctalia/settings.json";
        };

        home.file.profilePicture = {
          target = "${config.home.homeDirectory}/.face";
          # Use relative path instead of ${self} to avoid reevaluating
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
