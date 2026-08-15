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

      # Basic libraries
      (self.factory.diskoBrtfsEphemeralRoot
        {device = "/dev/nvme0n1";})
      self.nixosModules.preservation
      self.nixosModules.sopsNix

      # System config
      self.nixosModules.btrbk

      # Nix-related
      self.nixosModules.comin
      self.nixosModules.setupAccessTokens

      # Services
      self.nixosModules.fwudp
      self.nixosModules.openssh
      self.nixosModules.resticDefaults
      self.nixosModules.tailscale

      self.nixosModules.commander
    ];

    # Convenience programs
    environment.systemPackages = [
      pkgs.btop
      pkgs.tree
    ];

    # Allow SSH into root
    users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];

    # Enable passwordless sudo
    security.sudo.wheelNeedsPassword = false;

    # Automatically auth into Tailscale as a server
    services.tailscale = {
      authKeyFile = config.sops.secrets.tailscale-auth-key.path;
    };
    sops.secrets.tailscale-auth-key = {};

    # Only allow SSH via Tailscale
    services.openssh.openFirewall = false;
    networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = config.services.openssh.ports;

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
        STOP_CHARGE_THRESH_BAT0 = 60;
        START_CHARGE_THRESH_BAT1 = 40;
        STOP_CHARGE_THRESH_BAT1 = 60;
      };
    };

    # Turn off monitor after 1 minute idle
    boot.kernelParams = ["consoleblank=60"];

    # Save space, use git history as the primary way to rollback instead of boot entries
    boot.loader.systemd-boot.configurationLimit = 3;

    system.stateVersion = "25.11";
  };
}
