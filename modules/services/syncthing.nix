{
  config,
  lib,
  ...
}: let
  cfg = config.my.syncthing;
in {
  imports = [
    (lib.mkAliasOptionModule
      ["my" "syncthing" "devices"]
      ["services" "syncthing" "settings" "devices"])
    (lib.mkAliasOptionModule
      ["my" "syncthing" "folders"]
      ["services" "syncthing" "settings" "folders"])
  ];

  options.my.syncthing = {
    enable = lib.mkEnableOption "Syncthing";
    user = lib.mkOption {
      type = lib.types.str;
      default = "queze";
      description = "User that runs Syncthing.";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "users";
      description = "Group that runs Syncthing.";
    };
    guiUsername = lib.mkOption {
      type = lib.types.str;
      default = "queze";
      description = "Username for the Syncthing web interface.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.my.sops.enable;
        message = "my.syncthing.enable requires my.sops.enable.";
      }
      {
        assertion = lib.all (
          folder: lib.all (device: builtins.hasAttr device cfg.devices) folder.devices
        ) (lib.attrValues cfg.folders);
        message = "Every my.syncthing folder device must be declared in my.syncthing.devices.";
      }
    ];

    sops.secrets.syncthing-gui-password = {
      owner = cfg.user;
      group = cfg.group;
      restartUnits = ["syncthing-init.service"];
    };

    services.syncthing = {
      enable = true;
      guiAddress = "127.0.0.1:8384";
      dataDir = "/home/${cfg.user}";
      user = cfg.user;
      group = cfg.group;
      guiPasswordFile = config.sops.secrets.syncthing-gui-password.path;
      settings = {
        gui.user = cfg.guiUsername;
      };
    };

    # Open ports on Tailscale
    networking.firewall.interfaces.${config.services.tailscale.interfaceName} = {
      allowedTCPPorts = [22000];
      allowedUDPPorts = [
        21027
        22000
      ];
    };

    my.preservation.extraUserDirectories = [".config/syncthing"];
  };
}
