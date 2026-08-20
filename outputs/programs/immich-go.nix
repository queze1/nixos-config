{
  flake.homeModules.immichGo = {
    config,
    pkgs,
    ...
  }: {
    home.packages = [
      (pkgs.writeShellScriptBin "immich-go" ''
        exec ${pkgs.immich-go}/bin/immich-go \
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
  };
}
