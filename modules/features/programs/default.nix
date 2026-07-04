{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.allPrograms = {pkgs, ...}: {
    imports = [
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

      # Development
      self.homeModules.devenv
      self.homeModules.direnv
      self.homeModules.git
      self.homeModules.llmTools

      # CLI apps
      self.homeModules.foot
      self.homeModules.imv
      self.homeModules.yazi
      self.homeModules.nvf

      # GUI apps
      self.homeModules.firefox
      self.homeModules.keepassxc
      self.homeModules.obsidian
      self.homeModules.qutebrowser
      self.homeModules.vesktop
    ];

    home.packages = with pkgs; [
      gnome-clocks
      kdePackages.okular
      obs-studio
      pinta
      pkgs-stable.celluloid
      pkgs-stable.qimgv
      qalculate-qt

      # Nix-related CLI tools
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena

      # CLI tools
      clipboard-jh
      fastfetch
      ffmpeg
      pkgs-stable.yt-dlp
      tree
      unzip
      wl-clipboard
    ];

    programs.btop = {
      enable = true;
      settings = {
        theme_background = false;
      };
    };
    programs.nix-index-database.comma.enable = true;
  };
}
