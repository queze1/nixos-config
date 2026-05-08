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
      "image/jpeg" = [ "swayimg.desktop" ];
      "image/png" = [ "swayimg.desktop" ];
      "image/gif" = [ "swayimg.desktop" ];
      "image/webp" = [ "swayimg.desktop" ];
      "image/bmp" = [ "swayimg.desktop" ];
      "image/tiff" = [ "swayimg.desktop" ];
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
    pkgs-stable.qimgv
    qalculate-qt
    swayimg
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
