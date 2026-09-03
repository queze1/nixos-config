{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.imv;
in {
  options.my.programs.imv.enable = lib.mkEnableOption "imv" // {default = config.my.programs.enableAll;};

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({pkgs, ...}: let
        mogrify = lib.getExe' pkgs.imagemagick "mogrify";
      in {
        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "image/jpeg" = ["imv.desktop"];
            "image/png" = ["imv.desktop"];
            "image/gif" = ["imv.desktop"];
            "image/webp" = ["imv.desktop"];
            "image/bmp" = ["imv.desktop"];
            "image/tiff" = ["imv.desktop"];
          };
        };

        programs.imv = {
          enable = true;
          settings = {
            binds = {
              # Navigate with Vim keys
              h = "prev";
              l = "next";

              # Pan with arrow keys
              "<Left>" = "pan 50 0";
              "<Right>" = "pan -50 0";
              "<Up>" = "pan 0 50";
              "<Down>" = "pan 0 -50";

              # Rotate with imagemagick
              "<Shift+R>" = "exec ${mogrify} -rotate 90 $imv_current_file";
              "<Shift+E>" = "exec ${mogrify} -rotate -90 $imv_current_file";
            };
          };
        };
      })
    ];
  };
}
