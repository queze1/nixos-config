{
  flake.homeModules.vesktop = {
    programs.vesktop = {
      enable = true;
      # TODO: Add themes from GitHub repo and delete GitHub repo
      vencord = {
        # Very painful to convert to Nix manually!
        # If settings change, either find an automatic JSON -> Nix converter or do builtins.readJSON
        settings = {
          plugins = {
            CommandsAPI.enabled = true;
            DynamicImageModalAPI.enabled = true;
            MessageAccessoriesAPI.enabled = true;
            MessageEventsAPI.enabled = true;
            MessageUpdaterAPI.enabled = true;
            UserSettingsAPI.enabled = true;
            AccountPanelServerProfile = {
              enabled = true;
              prioritizeServerProfile = false;
            };
            BetterFolders = {
              enabled = true;
              sidebar = true;
              showFolderIcon = 1;
              keepIcons = false;
              closeAllHomeButton = false;
              closeAllFolders = false;
              forceOpen = false;
              sidebarAnim = true;
              closeOthers = false;
            };
            ClearURLs.enabled = true;
          };
          CrashHandler.enabled = true;
          FakeNitro.enabled = true;
          FullSearchContext.enabled = true;
          MessageLogger = {
            enabled = true;
            deleteStyle = "text";
            logDeletes = true;
            collapseDeleted = false;
            logEdits = false;
            inlineEdits = false;
            ignoreBots = false;
            ignoreSelf = true;
            ignoreUsers = "";
            ignoreChannels = "";
            ignoreGuilds = "";
          };
          NoUnblockToJump.enabled = true;
          ViewIcons.enabled = true;
          WebKeybinds.enabled = true;
          WebScreenShareFixes.enabled = true;
          WhoReacted.enabled = true;
          BadgeAPI.enabled = true;
          NoTrack = {
            enabled = true;
            disableAnalytics = true;
          };
          DisableDeepLinks.enabled = true;
          SupportHelper.enabled = true;
          WebContextMenus.enabled = true;
          ContextMenuAPI.enabled = true;
          MenuItemDemanglerAPI.enabled = true;
          NoticesAPI.enabled = true;
        };
      };
    };
  };
}
