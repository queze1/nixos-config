{
  flake.nixosModules.ddns = {config, ...}: let
    tailscale = "${config.services.tailscale.package}/bin/tailscale";
  in {
    # Dynamically update Cloudflare DNS with Tailscale IP
    services.ddclient = {
      enable = true;
      usev4 = ''cmdv4, cmdv4="${tailscale} ip --4"'';
      usev6 = ''cmdv6, cmdv6="${tailscale} ip --6"'';
      protocol = "cloudflare";
      zone = "osipol.uk";
      passwordFile = config.sops.secrets.cloudflare-api-token.path;
      username = "token";
    };

    systemd.services.ddclient = {
      requires = ["tailscaled.service"];
      wants = ["tailscaled.service"];
    };
  };
}
