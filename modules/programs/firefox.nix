{
  config,
  lib,
  ...
}: let
  myCfg = config.my.programs.firefox;
in {
  options.my.programs.firefox.enable = lib.mkEnableOption "Firefox" // {default = config.my.programs.enableAll;};

  config = lib.mkIf myCfg.enable {
    home-manager.sharedModules = [
      ({
        config,
        pkgs,
        ...
      }: let
        cfg = config.programs.firefox;
      in {
        # Preserve Firefox data
        my.home.preservation.extraDirectories = [cfg.configPath];

        # Set Firefox as default browser
        xdg.mimeApps.defaultApplications = {
          "x-scheme-handler/http" = "firefox.desktop";
          "x-scheme-handler/https" = "firefox.desktop";
          "text/html" = "firefox.desktop";
        };

        programs.firefox = {
          enable = true;
          configPath = "${config.home.homeDirectory}/.mozilla/firefox";
          policies = {
            DisableTelemetry = true;
            GenerativeAI = false;
            OfferToSaveLoginsDefault = false;
          };

          profiles.default = {
            settings = {
              "browser.tabs.insertAfterCurrent" = true;
              "browser.aboutConfig.showWarning" = false;
              "sidebar.verticalTabs" = true;
              "sidebar.main.tools" = "browser-extension@anonaddy,{bd97f89b-17ba-4539-9fec-06852d07f917}";
              "widget.use-xdg-desktop-portal.file-picker" = 1;
              "gfx.font_rendering.fontconfig.max_generic_substitution" = 127;
            };

            search = {
              force = true;
              default = "Brave";
              privateDefault = "Brave";

              engines = {
                "Brave" = {
                  urls = [
                    {
                      template = "https://search.brave.com/search";
                      params = [
                        {
                          name = "q";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  icon = "https://cdn.search.brave.com/serp/v1/static/brand/12832ccf4a94a6fe2ecc75f7ee0df48677abeab018d165ce25b7414477384367-favicon-96x96.png";
                  definedAliases = ["@brave"];
                };
                "SearXNG" = {
                  urls = [
                    {
                      template = "https://searxng.osipol.uk/search";
                      params = [
                        {
                          name = "q";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];
                  icon = "https://searxng.osipol.uk/favicon.ico";
                  definedAliases = ["@searxng"];
                };
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
                  definedAliases = ["@np"];
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
                  definedAliases = ["@no"];
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
                  definedAliases = ["@nho"];
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
                  definedAliases = ["@nw"];
                };
              };
            };
          };
        };
      })
    ];
  };
}
