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
      # Monitoring
      self.nixosModules.beszel
      self.nixosModules.beszelAgent
    ];

    # System config
    my.boot = {
      systemdBoot.enable = true;
      useLatestLtsKernel = true;
      configurationLimit = 3;
    };
    my.localisation.enable = true;
    my.networkManager.enable = true;
    zramSwap.enable = true;

    # Disk configuration
    my.disko.btrfsEphemeralRoot.device = "/dev/vda";
    my.preservation.enable = true;
    my.btrbk.enable = true;

    # Secret management
    my.sops.enable = true;

    # Services
    my.fwupd.enable = true;
    my.openssh.enable = true;
    my.tailscale = {
      enable = true;
      autoAuth = true;
      openSSHOnTailscale = true;
    };

    # Nix-related config
    my.deployment.comin.enable = true;
    my.nix = {
      enable = true;
      settings.download-buffer-size = 5000000;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      binaryCache.enable = true;
      accessTokens.enable = true;
    };

    # Personalisation
    my.editor.vim.enable = true;

    # Convenience programs
    environment.systemPackages = [
      pkgs.btop
      pkgs.tree
    ];

    my.users.commander.enable = true;

    # Allow SSH into root
    users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];

    # Enable passwordless sudo
    security.sudo.wheelNeedsPassword = false;

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

    system.stateVersion = "25.11";
  };
}
