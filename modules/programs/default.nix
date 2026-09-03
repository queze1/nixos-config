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
          pkgs.gnome-clocks
          pkgs.pinta
          pkgs.qalculate-qt
          pkgs-stable.celluloid

          # CLI tools
          inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena
          inputs.tumblr-utils.packages.${pkgs.stdenv.hostPlatform.system}.default
          pkgs.ncdu
          pkgs.npins
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
