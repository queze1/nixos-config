{
  pkgs,
  pkgs-stable,
  ...
}:

{
  imports = [
    ./firefox.nix
    ./git.nix
    ./nvf
    ./qutebrowser
    ./shell.nix
    ./yazi.nix
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = [ "imv.desktop" ];
      "image/png" = [ "imv.desktop" ];
      "image/gif" = [ "imv.desktop" ];
      "image/webp" = [ "imv.desktop" ];
      "image/bmp" = [ "imv.desktop" ];
      "image/tiff" = [ "imv.desktop" ];
    };
  };

  home.packages = with pkgs; [
    # Apps
    obsidian
    # (obsidian.override {
    #   commandLineArgs = "--ozone-platform=x11";
    # })
    calibre
    digikam
    gnome-clocks
    kdePackages.dolphin
    kdePackages.okular
    keepassxc
    obs-studio
    pinta
    pkgs-stable.celluloid
    pkgs-stable.qimgv
    qalculate-qt
    vesktop

    # CLI tools
    clipboard-jh
    fastfetch
    ffmpeg
    imagemagick
    libsecret
    pkgs-stable.yt-dlp
    pywalfox-native
    sshfs
    tree
    unzip
    wl-clipboard
    xclip

    # AI tools
    codex
    cursor-cli
    gemini-cli
    github-copilot-cli

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
}
