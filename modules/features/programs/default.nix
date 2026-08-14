{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.allPrograms = {
    imports = [
      self.sharedModules.pkgsStableOverlay
      self.nixosModules.fish
      self.nixosModules.protonvpn
    ];

    home-manager.sharedModules = [
      self.homeModules.allPrograms
    ];

    programs.seahorse.enable = true;
  };

  flake.homeModules.allPrograms = {pkgs, ...}: {
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
      # self.homeModules.immichGo
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

    home.packages = with pkgs; [
      calibre
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
      (pkgs.writeShellScriptBin "immich-go" ''
        exec ${pkgs.immich-go}/bin/immich-go \
          --server https://photos.example.com \
          --api-key-file /run/secrets/immich-api-key \
          "$@"
      '')
    ];

    programs.btop = {
      enable = true;
      settings = {
        theme_background = false;
      };
    };
    programs.nix-index-database.comma.enable = true;
  };

  flake.sharedModules.pkgsStableOverlay = {
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
  };
}
