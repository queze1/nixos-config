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

  home.packages = with pkgs; [
    # Apps
    (obsidian.override {
      commandLineArgs = "--ozone-platform=x11";
    })
    digikam
    gnome-clocks
    kdePackages.dolphin
    keepassxc
    obs-studio
    pinta
    pkgs-stable.celluloid
    vesktop

    # CLI tools
    fastfetch
    ffmpeg
    sshfs
    tree
    unzip
    wl-clipboard
    xclip
    pkgs-stable.yt-dlp

    # Theming
    pywalfox-native

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
