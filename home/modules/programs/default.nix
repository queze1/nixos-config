{
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
    ./yazi.nix
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
    yt-dlp

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
