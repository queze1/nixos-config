{
  config,
  lib,
  ...
}: let
  musicDir = "/srv/music";
  musicGid = 986;
in {
  imports = [
    ./navidrome.nix
    ./metube.nix
    ./yubal.nix
    ./picard.nix
  ];

  options.my.apps.music-stack.enable = lib.mkEnableOption "music stack";

  config =
    lib.mkIf (
      config.my.apps.music-stack.enable
      || config.my.apps.navidrome.enable
      || config.my.apps.metube.enable
      || config.my.apps.yubal.enable
      || config.my.apps.picard.enable
    ) {
      # Create group with shared access to the music directory
      users.groups.music = {
        gid = musicGid;
      };

      # Preserve music directory
      my.preservation.extraDirectories = [
        {
          directory = musicDir;
          user = "root";
          group = "music";
          mode = "2770";
        }
      ];

      # Back up music directory
      my.restic.extraPaths = [musicDir];

      # Ensure any new files are accessible by the music group
      systemd.tmpfiles.settings.music = {
        "/srv/music"."a+" = {
          argument = "default:group:music:rwx";
        };
      };
    };
}
