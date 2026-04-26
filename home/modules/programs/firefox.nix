{
  pkgs,
  config,
  hypervisor,
  ...
}:

let
  # Duplicated from /home/queze/etc/nixos/home/modules/desktop/plasma-manager.nix
  # Factor out later
  homeDirectory =
    if hypervisor == "vmware" then
      "/mnt/hgfs/VMShared"
    else if hypervisor == "utm" then
      "/mnt/utm"
    else
      config.home.homeDirectory;
in
{
  programs.firefox = {
    enable = true;
    configPath = "${config.home.homeDirectory}/.mozilla/firefox";
    policies = {
      DisableTelemetry = true;
      GenerativeAI = false;
      OfferToSaveLoginsDefault = false;
      DefaultDownloadDirectory = "${homeDirectory}/Downloads";
    };

    profiles.default = {
      settings = {
        "browser.tabs.insertAfterCurrent" = true;
        "browser.aboutConfig.showWarning" = false;
        "sidebar.verticalTabs" = true;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "gfx.canvas.accelerated" = false; # fixes broken PDFs in VMs
        "gfx.font_rendering.fontconfig.max_generic_substitution" = 127;
      };

      search = {
        force = true;
        default = "google";
        privateDefault = "google";

        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "Nix Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };
          "Home Manager Options" = {
            urls = [
              {
                template = "https://home-manager-options.extranix.com/";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nho" ];
          };

          "NixOS Wiki" = {
            urls = [
              {
                template = "https://wiki.nixos.org/w/index.php";
                params = [
                  {
                    name = "search";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nw" ];
          };
        };
      };
    };
  };
}
