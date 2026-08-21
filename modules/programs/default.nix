{
  config,
  inputs,
  lib,
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
          pkgs.calibre
          pkgs.gnome-clocks
          pkgs.kdePackages.okular
          pkgs.pinta
          pkgs.qalculate-qt
          pkgs-stable.celluloid
          inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena
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
      })
    ];
  };
}
