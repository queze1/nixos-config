{self, ...}: {
  # Configuration needed for a laptop server
  flake.nixosModules.laptopServer = {config, ...}: {
    imports = [
      self.nixosModules.fwudp
    ];

    # Declaratively configure wifi
    networking.networkmanager.ensureProfiles = {
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
    sops.secrets.home-wifi-env = {};

    # Don't sleep on lid close
    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };

    # Preserve battery health
    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };
  };
}
