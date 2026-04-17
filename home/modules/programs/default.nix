{
  inputs,
  pkgs,
  pkgs-stable,
  ...
}:

{
  imports = [
    ./firefox.nix
    ./git.nix
    ./shell.nix
    ./nvf.nix
  ];

  home.packages = with pkgs; [
    # Apps
    digikam
    kdePackages.dolphin
    keepassxc
    obsidian
    obs-studio
    pinta
    pkgs-stable.celluloid
    vesktop

    # CLI tools
    fastfetch
    ffmpeg
    gemini-cli
    sshfs
    tree
    unzip
    wl-clipboard
    xclip

    (tree-sitter.overrideAttrs (oldAttrs: rec {
      version = "0.26.8";
      patches = [ ];
      src = pkgs.fetchFromGitHub {
        owner = "tree-sitter";
        repo = "tree-sitter";
        tag = "v${version}";
        hash = "sha256-fcFEfoALrbpBD6rWogxJ7FNVlvDQgswoX9ylRgko+8Q=";
        fetchSubmodules = true;
      };
      cargoHash = "";
    }))

    # Theming
    pywalfox-native

    # Development tools
    nil
    nixfmt
    nodejs_22
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
    java = {
      enable = true;
      package = pkgs.jdk21;
    };
    nix-index-database.comma.enable = true;
    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };
    yazi = {
      enable = true;
      shellWrapperName = "y";
      plugins.bunny = "${inputs.bunny-yazi}";
      initLua = ''
        require("bunny"):setup({
          hops = {
            { key = "/",          path = "/",                                     },
            { key = "t",          path = "/tmp",                                  },
            { key = "n",          path = "/nix/store",         desc = "Nix store" },
            { key = "~",          path = "/mnt/utm",                              },
            { key = "m",          path = "/mnt/utm/Music",                        },
            { key = "d",          path = "/mnt/utm/Downloads",                    },
            { key = "D",          path = "/mnt/utm/Documents",                    },
            { key = "p",          path = "/mnt/utm/Pictures",                     },
            { key = "v",          path = "/mnt/utm/Videos",                       },
            { key = "o",          path = "/mnt/utm/Documents/obsidian",           },
          },
          desc_strategy = "path", -- If desc isn't present, use "path" or "filename", default is "path"
          ephemeral = true, -- Enable ephemeral hops, default is true
          tabs = true, -- Enable tab hops, default is true
          notify = false, -- Notify after hopping, default is false
          fuzzy_cmd = "fzf", -- Fuzzy searching command, default is "fzf"
        })
      '';
      keymap.mgr.prepend_keymap = [
        {
          on = ";";
          run = "plugin bunny";
          desc = "Start bunny.yazi";
        }
      ];
    };
  };

  services.syncthing = {
    enable = true;
    settings = {
      devices = {
        "poco-x3-pro" = {
          id = "CGN4GSA-JX3232W-WM5XXI6-RKU3W6F-RVAZH7N-YPOCAF3-52SRDUO-HHRFFQI";
        };
      };
      folders = {
        "SillyTavern Data" = {
          id = "nicrf-adfwa";
          path = "/mnt/utm/Apps/SillyTavern-Launcher/SillyTavern/data/default-user";
          devices = [ "poco-x3-pro" ];
        };
        "Music" = {
          id = "ft74r-2c4sc";
          path = "/mnt/utm/Music";
          devices = [ "poco-x3-pro" ];
        };
      };
    };
  };
}
