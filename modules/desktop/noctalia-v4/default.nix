{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.my.desktop.noctaliaV4;
in {
  options.my.desktop.noctaliaV4.enable = lib.mkEnableOption "Noctalia V4";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({config, ...}: let
        settings = builtins.fromJSON (builtins.readFile ./settings.json);
        modifiedSettings =
          settings
          // {
            general.avatarImage = "${inputs.secrets}/assets/pfp.png";
            wallpaper = {
              directory = "${config.xdg.userDirs.pictures}/Wallpapers";
            };
          };
      in {
        imports = [inputs.noctalia-v4.homeModules.default];

        programs.noctalia-shell = {
          enable = true;
          settings = modifiedSettings;
        };

        home.shellAliases = {
          noctalia-export = "noctalia-shell ipc call state all | nix run nixpkgs#jq .settings > ~/etc/nixos/modules/desktop/noctalia-v4/settings.json";
        };

        home.file.".cache/noctalia/wallpapers.json" = {
          text = builtins.toJSON {
            defaultWallpaper = "${inputs.secrets}/assets/laine-chinensy-temptation-v6.png";
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
