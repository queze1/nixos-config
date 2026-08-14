{
  flake.homeModules.immichGo = {
    config,
    pkgs,
    ...
  }: {
    # NOTE: no --api-key-file, need to use config file
    home.packages = [
      (pkgs.writeShellScriptBin "immich-go" ''
        exec ${pkgs.immich-go}/bin/immich-go \
          --server https://immich.osipol.uk \
          --api-key-file ${config.sops.secrets.immich-api-key.path} \
          "$@"
      '')
    ];

    sops.secrets.immich-api-key = {};
  };
}
