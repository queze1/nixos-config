{
  flake.nixosModules.myOptions = {lib, ...}: {
    options.my.preservation = {
      extraDirectories = lib.mkOption {
        type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
        default = [];
        example = [
          "/var/lib/syncthing"
          {
            directory = "/var/lib/tailscale";
            mode = "0700";
          }
        ];
        description = "Extra directories to preserve.";
      };
      extraUserDirectories = lib.mkOption {
        type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
        default = [];
        description = "Extra user directories to preserve.";
      };
      systemdServices = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "Systemd service configurations to apply ONLY if preservation is active.";
      };
    };
  };
}
