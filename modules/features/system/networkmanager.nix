{
  flake.nixosModules.networkmanager = {
    networking.networkmanager.enable = true;

    my.preservation.extraDirectories = [
      "/etc/NetworkManager/system-connections"
    ];
  };
}
