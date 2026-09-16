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

          # Development
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
      })
    ];
  };
}
