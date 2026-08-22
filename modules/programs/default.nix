{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.programs;

  ytDlpVersion = "2026.08.19";
  yt-dlp-patched = pkgs.yt-dlp.overrideAttrs rec {
    version = ytDlpVersion;
    src = pkgs.fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      tag = version;
      hash = "sha256-BM5ZeGTmHq+1xH6G/zsuCtjLgYgfRA11ya0zIHK5p4g=";
    };
  };
in {
  options.my.programs.enableAll = lib.mkEnableOption "all programs";

  config = lib.mkIf cfg.enableAll {
    assertions = [
      {
        assertion = lib.versionOlder pkgs.yt-dlp.version ytDlpVersion;
        message = "yt-dlp override must be newer than upstream";
      }
    ];

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
          yt-dlp-patched
          pkgs.clipboard-jh
          pkgs.ncdu
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
