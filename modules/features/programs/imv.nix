{
  flake.homeModules.imv = {
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

    # TODO: Fix not rotating
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
        };
      };
    };
  };
}
