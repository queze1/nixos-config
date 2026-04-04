{
  pkgs,
  pkgsStable,
  config,
  hypervisor,
  ...
}:
let
  # Duplicated from /home/andrewh/etc/nixos/home/modules/desktop/plasma-manager.nix
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
  imports = [
    ./git.nix
    ./shell.nix
    ./syncthing.nix
  ];

  home.packages = with pkgs; [
    # Apps
    digikam
    kdePackages.dolphin
    keepassxc
    obsidian
    pinta
    pkgsStable.celluloid
    vesktop

    # CLI tools
    fastfetch
    gemini-cli
    sshfs
    tree
    wf-recorder
    wl-clipboard

    # Theming
    pywalfox-native

    # Development tools
    nil
    nixfmt
    nodejs
    yarn

    # Force Audacity to use native Wayland
    (symlinkJoin {
      name = "audacity-wayland-fix";
      paths = [ audacity ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/audacity \
          --set GDK_BACKEND wayland
      '';
    })
  ];

  programs = {
    alacritty = {
      enable = true;
      settings = {
        terminal.shell.program = "${pkgs.fish}/bin/fish";
      };
    };
    firefox = {
      enable = true;
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
          "gfx.font_rendering.fontconfig.max_generic_substitution" = 127;
        };

        search = {
          force = true;
          default = "ddg";
          privateDefault = "ddg";

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
    java = {
      enable = true;
      package = pkgs.jdk21;
    };
    nix-index-database.comma.enable = true;
    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };
  };
}
