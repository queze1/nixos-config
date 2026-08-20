{
  # Service for updating firmware
  flake.nixosModules.fwudp = {
    services.fwupd.enable = true;

    my.preservation.extraDirectories = ["/var/lib/fwupd"];
  };
}
