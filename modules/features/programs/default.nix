{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.allPrograms = {pkgs, ...}: {
    imports = [
      self.nixModules.sharedPrograms
      self.nixosModules.fish
    ];

    services.mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };
    programs.seahorse.enable = true;
  };

  flake.darwinModules.allPrograms = {
    imports = [
      self.nixModules.sharedPrograms
    ];
  };

  flake.nixModules.sharedPrograms = {
    # Set pkgs.stable to nixpkgs on stable branch
    nixpkgs.overlays = [
      # deadnix: skip
      (final: prev: {
        stable = import inputs.nixpkgs-stable {
          system = final.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
      })
    ];

    home-manager.sharedModules = [
      self.homeModules.sharedPrograms
    ];
  };

  # Programs shared between nix-darwin and NixOS
  # TODO: Extract out programs which are not needed by nix-darwin
  flake.homeModules.sharedPrograms = {pkgs, ...}: {
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
      self.homeModules.imv
      self.homeModules.nvf
      self.homeModules.yazi

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
      qalculate-qt
      stable.celluloid
      stable.qimgv

      # Nix-related CLI tools
      inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena

      # CLI tools
      clipboard-jh
      fastfetch
      ffmpeg
      sops
      stable.yt-dlp
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
