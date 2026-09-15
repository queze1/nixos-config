{
  config,
  lib,
  self,
  pkgs,
  ...
}: let
  cfg = config.my.programs.steam;
  creamlinux = self.packages.${pkgs.stdenv.hostPlatform.system}.creamlinux-installer;
in {
  options.my.programs.steam = {
    enable = lib.mkEnableOption "Steam";
    creamlinux.enable = lib.mkEnableOption "CreamLinux";
  };

  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;

    environment.systemPackages = lib.optional cfg.creamlinux.enable creamlinux;

    my.preservation.extraUserDirectories =
      [
        ".local/share/Steam"
        ".steam"
      ]
      ++ lib.optionals cfg.creamlinux.enable [
        ".config/creamlinux"
        ".cache/creamlinux"
      ];
  };
}
