{
  flake.nixosModules.sharedModules = {
    networking.nftables.enable = true;
    networking.networkmanager.enable = true;
    my.preservation.extraDirectories = [
      "/etc/NetworkManager/system-connections"
    ];

    zramSwap.enable = true;

    # Set Vim as default editor
    environment.variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };
}
