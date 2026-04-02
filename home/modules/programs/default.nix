{
  pkgs,
  ...
}:
{
  imports = [
    ./git.nix
    ./shell.nix
    ./syncthing.nix
  ];

  home.packages = with pkgs; [
    # Apps
    # celluloid
    keepassxc
    obsidian
    pinta
    vesktop

    # CLI tools
    gemini-cli
    sshfs
    tree
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
  ];

  programs = {
    firefox.enable = true;
    kitty.enable = true;
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
