{
  config,
  inputs,
  lib,
  self,
  ...
}: let
  cfg = config.my.programs;
in {
  options.my.programs.enableAll = lib.mkEnableOption "all programs";

  config = lib.mkIf cfg.enableAll {
    programs.seahorse.enable = true;

    home-manager.sharedModules = [
      ({
        pkgs,
        pkgs-stable,
        ...
      }: {
        imports = [inputs.nix-index-database.homeModules.default];

        home.packages = let
          colmena = inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena;

          tumblrBackup = self.packages.${pkgs.stdenv.hostPlatform.system}.tumblr-backup;
          tumblrToEbook = self.packages.${pkgs.stdenv.hostPlatform.system}.tumblr-to-ebook;
        in [
          pkgs.gnome-clocks
          pkgs.pinta
          pkgs.qalculate-qt
          pkgs-stable.celluloid

          # CLI tools
          pkgs.ncdu
          pkgs.npins
          pkgs.sops
          pkgs.tree
          pkgs.unzip
          pkgs.wl-clipboard
          colmena
          tumblrBackup

          # Scripts
          tumblrToEbook
        ];

        programs.btop = {
          enable = true;
          settings = {
            theme_background = false;
          };
        };
        programs.nix-index-database.comma.enable = true;
      })
    ];
  };
}
