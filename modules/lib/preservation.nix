{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.my.preservation;
in {
  imports = [inputs.preservation.nixosModules.default];

  options.my.preservation = {
    enable = lib.mkEnableOption "preservation";
    extraDirectories = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
      default = [];
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
      description = "Extra files to preserve.";
    };

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Users whose home directories are preserved.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({lib, ...}: {
        options.my.home.preservation.extraDirectories = lib.mkOption {
          type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
          default = [];
          description = "Extra user directories to preserve.";
        };
      })
    ];

    preservation = {
      enable = true;
      preserveAt."/persistent" = {
        directories = lib.unique (
          [
            "/var/lib/systemd/coredump"
            "/var/lib/systemd/rfkill"
            "/var/lib/systemd/timers"
            "/var/log"
            {
              directory = "/var/lib/nixos";
              inInitrd = true;
            }
          ]
          ++ cfg.extraDirectories
        );
        files = lib.unique (
          [
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
            {
              file = "/etc/ssh/ssh_host_rsa_key";
              how = "symlink";
              configureParent = true;
            }
            {
              file = "/etc/ssh/ssh_host_ed25519_key";
              how = "symlink";
              configureParent = true;
            }
            {
              file = "/var/lib/systemd/random-seed";
              how = "symlink";
              inInitrd = true;
              configureParent = true;
            }
          ]
          ++ cfg.extraFiles
        );
        users = lib.genAttrs cfg.users (username: {
          commonMountOptions = ["x-gvfs-hide"];
          directories = lib.unique (
            [
              {
                directory = ".ssh";
                mode = "0700";
              }
              # Standard user directories
              "Desktop"
              "Documents"
              "Downloads"
              "Music"
              "Videos"
            ]
            # Merge directories added with NixOS and Home Manager
            ++ cfg.extraUserDirectories
            # Extract directories added with Home Manager
            ++ (config.home-manager.users.${username}.my.home.preservation.extraDirectories or [])
          );
        });
      };
    };

    systemd.services.systemd-machine-id-commit.enable = false;

    # By default, missing parent directories are always created with ownership
    # `root:root` and mode `0755`, as described in {manpage}`tmpfiles.d(5)`.
    # tmpfiles is the recommended way of fixing this.
    systemd.tmpfiles.settings.preservation = lib.mkMerge (
      map (username: {
        "/home/${username}/.config".d = {
          user = username;
          group = "users";
          mode = "0755";
        };
        "/home/${username}/.local".d = {
          user = username;
          group = "users";
          mode = "0755";
        };
        "/home/${username}/.local/share".d = {
          user = username;
          group = "users";
          mode = "0755";
        };
        "/home/${username}/.local/state".d = {
          user = username;
          group = "users";
          mode = "0755";
        };
      })
      cfg.users
    );
  };
}
