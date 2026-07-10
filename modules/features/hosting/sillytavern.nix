{
  flake.nixosModules.sillytavern = {
    services.sillytavern = {
      enable = true;
      port = 8045;
      listen = false;
      listenAddressIPv4 = "127.0.0.1";
      listenAddressIPv6 = "::1";
    };
  };
}
