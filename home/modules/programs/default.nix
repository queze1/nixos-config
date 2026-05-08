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
    ./nvf
    ./yazi.nix
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = [ "qimgv.desktop" ];
      "image/png" = [ "qimgv.desktop" ];
      "image/gif" = [ "qimgv.desktop" ];
      "image/webp" = [ "qimgv.desktop" ];
      "image/bmp" = [ "qimgv.desktop" ];
      "image/tiff" = [ "qimgv.desktop" ];
    };
  };

  home.packages = with pkgs; [
    # Apps
    (obsidian.override {
      commandLineArgs = "--ozone-platform=x11";
    })
    digikam
    gnome-clocks
    kdePackages.dolphin
    kdePackages.okular
    keepassxc
    obs-studio
    pinta
    pkgs-stable.celluloid
    qalculate-qt
    pkgs-stable.qimgv
    vesktop

    # CLI tools
    clipboard-jh
    fastfetch
    ffmpeg
    libsecret
    pkgs-stable.yt-dlp
    pywalfox-native
    sshfs
    tree
    unzip
    wl-clipboard
    xclip

    # AI tools
    cursor-cli
    codex
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
}
