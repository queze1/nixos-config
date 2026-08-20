{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.allPrograms = {
    imports = [
      self.nixosModules.fish
      self.nixosModules.protonvpn
    ];

    home-manager.sharedModules = [
      self.homeModules.allPrograms
    ];

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
      self.homeModules.cloudflaredClient
      self.homeModules.devenv
      self.homeModules.direnv
      self.homeModules.git
      self.homeModules.llmTools

      # CLI apps
      self.homeModules.foot
      self.homeModules.immichGo
      self.homeModules.imv
      self.homeModules.nvf
      self.homeModules.yazi

      # GUI apps
      self.homeModules.bitwardenClient
      self.homeModules.firefox
      self.homeModules.keepassxc
      self.homeModules.obsidian
      self.homeModules.qutebrowser
      self.homeModules.vesktop
    ];

    home.packages = [
      pkgs.calibre
      pkgs.gnome-clocks
      pkgs.kdePackages.okular
      pkgs.pinta
      pkgs.qalculate-qt
      pkgs-stable.celluloid

      # Nix-related CLI tools
      inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena

      # CLI tools
      pkgs.clipboard-jh
      pkgs.sops
      pkgs.tree
      pkgs.unzip
      pkgs.wl-clipboard
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
