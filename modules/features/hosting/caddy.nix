{inputs, ...}: {
  flake.nixosModules.caddy = {
    config,
    pkgs,
    ...
  }: {
    age.secrets.osipol-cloudflare-api-token.file = "${inputs.secrets}/osipol-cloudflare-api-token.age";

    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/cloudflare@v0.2.4"
        ];
        hash = "sha256-hEHgAG0F0ozHRAPuxEqLyTATBrE+pajeXDiSNwniorg=";
      };
      globalConfig = ''
        acme_dns cloudflare {file.${config.age.secrets.osipol-cloudflare-api-token.path}}
      '';

      virtualHosts = {
        "new.navidrome.osipol.uk" = {
          extraConfig = ''
            reverse_proxy localhost:4533
          '';
        };
      };
    };
  };
}
