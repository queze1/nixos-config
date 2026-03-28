{
  config,
  hypervisor ? null,
  ...
}:

let
  homeDirectory =
    if hypervisor == "vmware" then
      "/mnt/hgfs/VMShared"
    else if hypervisor == "utm" then
      "/mnt/utm"
    else
      config.home.homeDirectory;
in

{
  programs.plasma = {
    enable = true;

    # ==========================================
    # Panel Configuration
    # ==========================================
    panels = [
      {
        location = "bottom";
        height = 44;
        widgets = [
          # Start menu
          "org.kde.plasma.kickoff"

          # Virtual desktop wwitcher
          "org.kde.plasma.pager"

          # Pinned apps
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General.launchers = [
                "applications:org.kde.dolphin.desktop"
                "applications:firefox.desktop"
                "applications:org.keepassxc.KeePassXC.desktop"
                "applications:obsidian.desktop"
                "applications:vesktop.desktop"
                "applications:code.desktop"
              ];
            };
          }

          # Spacing, system tray, and clock
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];

    # ==========================================
    # Configuration Files
    # ==========================================
    configFile = {
      # Move files by default if dragged
      kdeglobals.KDE.DndBehavior = "MoveIfSameDevice";

      # Blue-light filter
      kwinrc.NightColor.Active = true;
      kwinrc.NightColor.NightTemperature = 3700;

      # Turn off "shake mouse to find cursor"
      kwinrc.Plugins.shakecursorEnabled = false;

      # Save screenshots to home
      "spectaclerc"."ImageSave" = {
        imageSaveLocation = "file://${homeDirectory}/Pictures/Screenshots";
        translatedScreenshotsFolder = "Screenshots";
      };

      # Dolphin
      kdeglobals.PreviewSettings.MaximumRemoteSize = 10485760000;
      "dolphinrc"."PreviewSettings"."Plugins" =
        "appimagethumbnail,audiothumbnail,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,svgthumbnail,ffmpegthumbs";
      "dolphinrc"."General"."ShowFullPathInTitlebar" = true;
    };
  };
}
