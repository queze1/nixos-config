{
  flake.nixosModules.printing = {
    config,
    lib,
    ...
  }: {
    config = lib.mkIf (! config.host.hypervisor.isGuest) {
      services.printing.enable = true;
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
  };
}
