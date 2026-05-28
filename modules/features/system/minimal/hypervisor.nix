{ self, ... }:
{
  flake.nixosModules.hypervisor =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.host.hypervisor;
    in
    {
      options.host = {
        hypervisor = {
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

          sharedFolder = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default =
              if config.host.hypervisor.type == "utm" then
                "/mnt/utm"
              else if config.host.hypervisor.type == "vmware" then
                "/mnt/hgfs"
              else
                null;
            description = "Where to mount the shared folder";
          };

          useForXDGUserDirs = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to place XDG user directories (e.g. Downloads, Documents) in the shared folder";
          };
        };
      };

      config = lib.mkMerge [
        {
          # Import helper HM module
          home-manager.sharedModules = [
            self.homeModules.xdgUserDirs
          ];
        }

        (lib.mkIf (cfg.type == "utm") {
          services.spice-vdagentd.enable = true;
          services.qemuGuest.enable = true;

          # Pretend to support OpenGL 3.3
          # environment.sessionVariables = {
          #   MESA_GL_VERSION_OVERRIDE = "3.3";
          #   MESA_GLSL_VERSION_OVERRIDE = "330";
          # };

          # Needed for shared directory
          boot.initrd.availableKernelModules = [
            "9p"
            "9pnet_virtio"
          ];

          systemd.tmpfiles.rules = [
            "d ${cfg.sharedFolder} 777 root root -"
          ];

          # Mount shared directory
          fileSystems."/mnt/utm" = {
            device = "share";
            fsType = "9p";
            options = [
              "trans=virtio"
              "version=9p2000.L"
              "rw"
              "_netdev"
              "nofail"
            ];
          };
        })

        (lib.mkIf (cfg.type == "vmware") {
          virtualisation.vmware.guest.enable = true;

          # DNS workaround
          networking.networkmanager.insertNameservers = [
            "1.1.1.1"
            "8.8.8.8"
          ];

          systemd.tmpfiles.rules = [
            "d ${cfg.sharedFolder} 755 root root -"
          ];

          # Mount shared directory
          systemd.mounts = [
            {
              what = ".host:/";
              where = "/mnt/hgfs";
              type = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
              options = "allow_other,uid=1000";
              wantedBy = [ "multi-user.target" ];
              after = [ "sys-fs-fuse-connections.mount" ];
            }
          ];
        })
      ];
    };

  # Modify XDG user directories if using shared folder for that
  flake.homeModules.xdgUserDirs =
    {
      lib,
      osConfig,
      ...
    }:
    let
      cfg = osConfig.host.hypervisor;
    in
    lib.mkIf (cfg.useForXDGUserDirs && cfg.sharedFolder != null) {
      xdg.userDirs = {
        enable = true;
        createDirectories = true; # create if missing
        download = "${cfg.sharedFolder}/Downloads";
        documents = "${cfg.sharedFolder}/Documents";
        pictures = "${cfg.sharedFolder}/Pictures";
        videos = "${cfg.sharedFolder}/Videos";
        music = "${cfg.sharedFolder}/Music";
      };
    };
}
