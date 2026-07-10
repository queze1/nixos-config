{
  flake.nixosModules.sillytavern = {
    services.sillytavern = {
      enable = true;
      port = 8045;
      listen = false;

      # https://tailscale.com/docs/reference/reserved-ip-addresses
      listenAddressIPv4 = "100.64.0.0/10";
      listenAddressIPv6 = "fd7a:115c:a1e0::/48";
    };
  };
}
