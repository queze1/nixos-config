{
  # Options which all hosts should have access to.
  # E.g. constants, options configuring modules which should silently do nothing if that module is not imported.
  flake.nixModules.myOptions = {lib, ...}: {
    options.my.constants = {
      tailnetDomain = lib.mkOption {
        type = lib.types.str;
        default = "tail8963fb.ts.net";
        description = "Tailnet DNS name.";
      };
    };

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
      extraFiles = lib.mkOption {
        type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
        default = [];
        example = [
          {
            file = "/etc/ssh/ssh_host_ed25519_key";
            how = "symlink";
            configureParent = true;
          }
        ];
        description = "Extra files to preserve.";
      };
    };
  };

  flake.homeModules.myOptions = {lib, ...}: {
    options.my.home.preservation = {
      extraDirectories = lib.mkOption {
        type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
        default = [];
        description = "Extra user directories to preserve.";
      };
    };
  };
}
