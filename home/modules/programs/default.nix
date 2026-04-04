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
    gemini-cli
    slurp
    sshfs
    tree

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
  };
}
