{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.preservationInterface = {lib, ...}: {
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
    };
  };

  flake.nixosModules.preservation = {config, ...}: {
    imports = [
      inputs.preservation.nixosModules.default
      self.nixosModules.preservationInterface
    ];

    preservation = {
      enable = true;
      preserveAt."/persistent" = {
        directories =
          [
            "/etc/NetworkManager/system-connections"
            "/var/lib/fwupd"
            "/var/lib/libvirt"
            "/var/lib/systemd/coredump"
            "/var/lib/systemd/rfkill"
            "/var/lib/systemd/timers"
            "/var/log"
            {
              directory = "/var/lib/nixos";
              inInitrd = true;
            }
          ]
          ++ config.my.preservation.extraDirectories;

        files = [
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
        ];
      };
    };

    # Prevent conflict with preservation
    systemd.services.systemd-machine-id-commit.enable = false;
  };

  flake.factory.preservationForUser = {username}: {config, ...}: {
    imports = [
      self.nixosModules.preservationInterface
    ];

    preservation.preserveAt."/persistent".users.${username} = {
      commonMountOptions = [
        "x-gvfs-hide"
      ];

      directories =
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
        ++ config.my.preservation.extraUserDirectories;
    };

    # By default, missing parent directories are always created with ownership
    # `root:root` and mode `0755`, as described in {manpage}`tmpfiles.d(5)`.
    # tmpfiles is the recommended way of fixing this.
    systemd.tmpfiles.settings.preservation = {
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
    };
  };
}
