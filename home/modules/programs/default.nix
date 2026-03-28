{
  pkgs,
  lib,
  desktop,
  ...
}:
{
  imports = [
    ./git.nix
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
    ]

    # Use Dolphin for GNOME
    ++ lib.optionals (desktop == "gnome") [
      kdePackages.dolphin
    ];

  programs = {
    firefox.enable = true;
    nix-index-database.comma.enable = true;
    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };
    java = {
      enable = true;
      package = pkgs.jdk21;
    };
  };
}
