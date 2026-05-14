{
  flake.nixosModules.standardSystem =
    { config, lib, ... }:
    {
      config = lib.mkIf (config.host.isGuest == false) {
        services.printing.enable = true;
        services.avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };
      };
    };
}
