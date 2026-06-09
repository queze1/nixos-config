{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.allPrograms = {pkgs, ...}: {
    imports = [
      self.nixosModules.minimalPrograms
      self.nixosModules.fish
    ];

    home-manager.sharedModules = [self.homeModules.allPrograms];

    services.mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };
    programs.seahorse.enable = true;
  };

  flake.homeModules.allPrograms = {
    pkgs,
    pkgs-stable,
    ...
  }: {
    imports = [
      inputs.nix-index-database.homeModules.default

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
      audacity
      calibre
      digikam
      gnome-clocks
      kdePackages.okular
      keepassxc
      obs-studio
      obsidian
      pinta
      pkgs-stable.celluloid
      pkgs-stable.qimgv
      qalculate-qt

      # CLI tools
      clipboard-jh
      fastfetch
      ffmpeg
      pkgs-stable.yt-dlp
      pywalfox-native
      xclip # for X11-Wayland sync on VMs

      # AI tools
      cursor-cli
      codex
      github-copilot-cli
    ];

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };
    programs.nix-index-database.comma.enable = true;
  };

  flake.nixosModules.minimalPrograms = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      sshfs
      tree
      unzip
      wl-clipboard
    ];

    programs.git = {
      enable = true;
      config = {
        user.name = "queze1";
        user.email = "52340127+queze1@users.noreply.github.com";
        init.defaultBranch = "main";
        push = {
          autoSetupRemote = "true";
        };
        alias = {
          ca = "commit -a --amend";
          cm = "commit -m";
          co = "checkout";
          s = "status";
        };
      };
    };

    # Set Vim as default editor
    environment.variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };
}
