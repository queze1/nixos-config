{
  config,
  inputs,
  lib,
  self,
  ...
}: let
  cfg = config.my.programs;
in {
  options.my.programs.enableDefault = lib.mkEnableOption "default programs";

  config = lib.mkIf cfg.enableDefault {
    programs.seahorse.enable = true;

    home-manager.sharedModules = [
      ({pkgs, ...}: {
        imports = [inputs.nix-index-database.homeModules.default];

        home.packages = let
          colmena = inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena;

          tumblrBackup = self.packages.${pkgs.stdenv.hostPlatform.system}.tumblr-backup;
          tumblrToEbook = self.packages.${pkgs.stdenv.hostPlatform.system}.tumblr-to-ebook;
        in [
          pkgs.celluloid
          pkgs.gnome-clocks
          pkgs.pinta
          pkgs.qalculate-qt

          # Development
          pkgs.act
          pkgs.flake-edit
          pkgs.github-cli
          pkgs.npins
          pkgs.sops
          colmena

          # CLI tools
          pkgs.ncdu
          pkgs.tree
          pkgs.unzip
          pkgs.wl-clipboard
          tumblrBackup
          tumblrToEbook
        ];

        programs.btop = {
          enable = true;
          settings = {
            theme_background = false;
          };
        };
        programs.nix-index-database.comma.enable = true;

        my.home.preservation.extraDirectories = [
          ".config/gh" # Github CLI
        ];
      })
    ];
  };
}
