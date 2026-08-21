{
  config,
  lib,
  ...
}: let
  cfg = config.my.networkManager;
in {
  options.my.networkManager = {
    enable = lib.mkEnableOption "NetworkManager and nftables";
    homeWifi = {
      enable = lib.mkEnableOption "the home Wi-Fi profile";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.nftables.enable = true;
    networking.networkmanager.enable = true;

    networking.networkmanager.ensureProfiles = lib.mkIf cfg.homeWifi.enable {
      environmentFiles = [config.sops.secrets.home-wifi-env.path];
      profiles.home-wifi = {
        connection = {
          id = "$WIFI_SSID";
          type = "wifi";
          uuid = "$WIFI_UUID";
          autoconnect = true;
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
        proxy = {};
        wifi = {
          mode = "infrastructure";
          ssid = "$WIFI_SSID";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "$WIFI_PSK";
        };
      };
    };
    sops.secrets = lib.mkIf cfg.homeWifi.enable {
      home-wifi-env = {};
    };

    my.preservation.extraDirectories = [
      "/etc/NetworkManager/system-connections"
    ];
  };
}
