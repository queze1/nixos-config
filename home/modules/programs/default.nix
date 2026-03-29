{
  pkgs,
  lib,
  desktop,
  ...
}:
{
  imports = [
    ./git.nix
    ./nvf
    ./shell.nix
  ];

  home.packages =
    with pkgs;
    [
      # GUI apps
      audacity
      celluloid
      keepassxc
      obsidian
      pinta
      vesktop

      # CLI tools
      gemini-cli
      rclone
      sshfs
      tree
      unzip
      wl-clipboard

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
    ]

    # Use Dolphin for GNOME
    ++ lib.optionals (desktop == "gnome") [
      kdePackages.dolphin
    ];

  programs = {
    firefox.enable = true;
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
