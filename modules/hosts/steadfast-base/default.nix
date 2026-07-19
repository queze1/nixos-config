{self, ...}: let
  sshKeys = import "${self}/ssh-keys.nix";
in {
  # Base configuration for home servers
  flake.nixosModules.steadfastBase = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.myOptions
      self.nixosModules.sharedModules
      self.nixosModules.networkmanager

      # Basic libraries
      self.nixosModules.preservation
      self.nixosModules.sopsNix

      # Services
      self.nixosModules.openssh
      self.nixosModules.tailscale

      self.nixosModules.commander
    ];

    # Convenience programs
    environment.systemPackages = [
      pkgs.htop
      pkgs.tree
    ];

    # Remember to lock root password after first use with "passwd -l root"
    users.users.root.initialPassword = "root";

    # Allow SSH into root
    users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];

    # Automatically auth into Tailscale as a server
    sops.secrets.tailscale-auth-key = {};
    services.tailscale = {
      authKeyFile = config.sops.secrets.tailscale-auth-key.path;
    };

    # Only allow SSH via Tailscale
    services.openssh.openFirewall = false;
    networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = config.services.openssh.ports;

    # Declaratively configure wifi
    sops.secrets.home-wifi-env = {};
    networking.networkmanager.ensureProfiles = {
      environmentFiles = [config.sops.secrets.home-wifi-env.path];
      profiles.home-wifi = {
        connection = {
          id = "$WIFI_SSID";
          interface-name = "wlp3s0";
          type = "wifi";
          uuid = "$WIFI_UUID";
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

    system.stateVersion = "25.11";
  };
}
