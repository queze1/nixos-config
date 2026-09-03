{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.immichGo;
in {
  options.my.programs.immichGo.enable = lib.mkEnableOption "immich-go" // {default = config.my.programs.enableAll;};

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({
        config,
        pkgs,
        ...
      }: {
        home.packages = [
          (pkgs.writeShellScriptBin "immich-go" ''
            exec ${lib.getExe pkgs.immich-go} \
              --config ${config.sops.templates."immich-go.toml".path} \
              "$@"
          '')
        ];

        sops.secrets.immich-api-key = {};

        sops.templates."immich-go.toml".content = ''
          [upload]
          api-key = "${config.sops.placeholder.immich-api-key}"
          server = "https://immich.osipol.uk"
        '';
      })
    ];
  };
}
