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

        home.packages = [
          pkgs-stable.celluloid
          pkgs.gnome-clocks
          pkgs.openshot-qt
          pkgs.pinta
          pkgs.qalculate-qt

          # CLI tools
          inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena
          inputs.tumblr-utils.packages.${pkgs.stdenv.hostPlatform.system}.default
          pkgs.ncdu
          pkgs.npins
          pkgs.sops
          pkgs.tree
          pkgs.unzip
          pkgs.wl-clipboard

          # Scripts
          self.packages.${pkgs.stdenv.hostPlatform.system}.tumblr-to-ebook
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
