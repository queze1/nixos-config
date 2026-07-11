{inputs, ...}: {
  flake.nixosModules.cloudflared = {config, ...}: {
    services.cloudflared = {
      enable = true;
      tunnels = {
        "b6ce003f-d222-4d1c-8e67-56ac678280ba" = {
          credentialsFile = "${config.age.secrets.osipol-cloudflare-creds.path}";
          default = "http_status:404";
        };
      };
    };

    age.secrets.osipol-cloudflare-creds = {
      file = "${inputs.secrets}/osipol-cloudflare-creds.age";
    };
  };
}
