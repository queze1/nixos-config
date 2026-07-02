{inputs, ...}: {
  flake.nixosModules.preservation = {
    config,
    lib,
    ...
  }: {
    imports = [
      inputs.preservation.nixosModules.default
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
          ++ lib.unique config.my.preservation.extraDirectories;

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

    systemd.services = lib.mkMerge [
      config.my.preservation.systemdServices
      {
        systemd-machine-id-commit.enable = false;
      }
    ];
  };

  flake.factory.preservationForUser = {username}: {
    config,
    lib,
    ...
  }: let
    hmUserConfig = config.home-manager.users.${username} or null;
    # Extract directories added with Home Manager
    hmDirectories =
      if hmUserConfig != null
      then hmUserConfig.my.home.preservation.directories or []
      else [];
  in {
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
        # Merge directories added with NixOS and Home Manager
        ++ lib.unique (config.my.preservation.extraUserDirectories ++ hmDirectories);
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
