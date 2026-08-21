{
  config,
  lib,
  ...
}: let
  cfg = config.my.networkManager;
in {
  options.my.networkManager = {
    enable = lib.mkEnableOption "NetworkManager and nftables";
    preserveConnections = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.nftables.enable = true;
    networking.networkmanager.enable = true;
    my.preservation.extraDirectories = lib.mkIf cfg.preserveConnections [
      "/etc/NetworkManager/system-connections"
    ];
  };
}
