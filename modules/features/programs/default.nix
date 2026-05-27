{ inputs, self, ... }:
{
  flake.nixosModules.allPrograms =
    { pkgs, ... }:
    {
      # Extend minimalPrograms
      imports = [ self.nixosModules.minimalPrograms ];

      services.mullvad-vpn = {
        enable = true;
        package = pkgs.mullvad-vpn;
      };

      home-manager.sharedModules = [ self.homeModules.allPrograms ];
    };

  # TODO: Configure pkgs-stable
  flake.homeModules.allPrograms =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.btop
        self.homeModules.firefox
        self.homeModules.foot
        self.homeModules.imv
        self.homeModules.nvf
        self.homeModules.qutebrowser
        self.homeModules.vesktop
        self.homeModules.yazi
      ];

      home.packages = with pkgs; [
        # TODO: Use overlay
        (obsidian.override {
          commandLineArgs = "--ozone-platform=x11";
        })
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

        digikam
        gnome-clocks
        kdePackages.okular
        keepassxc
        obs-studio
        pinta
        # pkgs-stable.celluloid
        # pkgs-stable.qimgv
        qalculate-qt

        # CLI tools
        clipboard-jh
        fastfetch
        ffmpeg
        # pkgs-stable.yt-dlp
        pywalfox-native
        xclip # for X11-Wayland sync on VMs

        # AI tools
        cursor-cli
        codex
        github-copilot-cli
      ];
    };

  flake.nixosModules.minimalPrograms = {
    imports = [ self.nixosModules.fish ];

    home-manager.sharedModules = [ self.homeModules.minimalPrograms ];
  };

  flake.homeModules.minimalPrograms =
    { pkgs, ... }:
    {
      imports = [
        inputs.nix-index-database.homeModules.default
        self.homeModules.git
      ];

      home.packages = with pkgs; [
        sshfs
        tree
        unzip
        wl-clipboard
      ];

      programs.direnv = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        nix-direnv.enable = true;
      };
      programs.nix-index-database.comma.enable = true;
    };
}
