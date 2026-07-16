{
  flake.nixosModules.ddns = {config, ...}: {
    # Dynamically update Cloudflare DNS with Tailscale IP
    services.ddclient = {
      enable = true;
      usev4 = "ifv4, ifv4=tailscale0";
      protocol = "cloudflare";
      zone = "osipol.uk";
      passwordFile = config.sops.secrets.osipol-cloudflare-api-token.path;
      username = "token";
    };
  };
}
