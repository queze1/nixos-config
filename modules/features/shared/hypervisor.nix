{
  flake.nixosModules.hypervisor = {
    config,
    lib,
    ...
  }: let
    cfg = config.host.hypervisor;
  in {
    options.host.hypervisor = {
      type = lib.mkOption {
        type = lib.types.enum [
          "utm"
          "vmware"
          "none"
        ];
        default = "none";
      };

      isGuest = lib.mkOption {
        type = lib.types.bool;
        default = config.host.hypervisor.type != "none";
        readOnly = true;
      };

      sharedFolder = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable the shared folder mount";
        };

        path = lib.mkOption {
          type = lib.types.str;
          default =
            if config.host.hypervisor.type == "utm"
            then "/mnt/utm"
            else if config.host.hypervisor.type == "vmware"
            then "/mnt/hgfs"
            else "/mnt/shared";
          description = "Where to mount the shared folder";
        };
      };

      useForXDGUserDirs = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to place XDG user directories (e.g. Downloads, Documents) in the shared folder";
      };
    };

    config = lib.mkMerge [
      (lib.mkIf (cfg.type == "utm") {
        services.spice-vdagentd.enable = true;
        services.qemuGuest.enable = true;

        # Needed for shared directory
        boot.initrd.availableKernelModules = [
          "9p"
          "9pnet_virtio"
        ];
        boot.kernelModules = [
          "9p"
          "9pnet_virtio"
        ];

        # Unideal because hardcoded
        systemd.tmpfiles.rules = lib.mkIf cfg.sharedFolder.enable [
          "d ${cfg.sharedFolder.path} 755 queze users -"
        ];

        # Mount shared directory
        fileSystems = lib.mkIf cfg.sharedFolder.enable {
          ${cfg.sharedFolder.path} = {
            device = "share";
            fsType = "9p";
            options = [
              "trans=virtio"
              "version=9p2000.L"
              "rw"
              "_netdev"
              "nofail"

              # Let NixOS do the access check
              "access=client"
              "uid=1000"
              "gid=100"

              # Set maximum message size to 512 KiB
              "msize=524288"
            ];
          };
        };
      })

      (lib.mkIf (cfg.type == "vmware") {
        virtualisation.vmware.guest.enable = true;

        # DNS workaround
        networking.networkmanager.insertNameservers = [
          "1.1.1.1"
          "8.8.8.8"
        ];

        systemd.tmpfiles.rules = lib.mkIf cfg.sharedFolder.enable [
          "d ${cfg.sharedFolder.path} 755 root root -"
        ];

        # Mount shared directory
        systemd.mounts = lib.mkIf cfg.sharedFolder.enable [
          {
            what = ".host:/";
            where = cfg.sharedFolder.path;
            type = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
            options = "allow_other,uid=1000";
            wantedBy = ["multi-user.target"];
            after = ["sys-fs-fuse-connections.mount"];
          }
        ];
      })
    ];
  };

  # Modify XDG user directories to match shared folder
  flake.homeModules.xdgUserDirs = {osConfig, ...}: let
    cfg = osConfig.host.hypervisor;
    xdgUserHome =
      if cfg.useForXDGUserDirs && cfg.sharedFolder.enable
      then cfg.sharedFolder.path
      else "~";
  in {
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = false;
      download = "${xdgUserHome}/Downloads";
      documents = "${xdgUserHome}/Documents";
      pictures = "${xdgUserHome}/Pictures";
      videos = "${xdgUserHome}/Videos";
      music = "${xdgUserHome}/Music";
    };
  };
}
