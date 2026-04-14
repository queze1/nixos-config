{
  lib,
  hypervisor ? null,
  ...
}:

{
  config = lib.mkMerge [
    (lib.mkIf (hypervisor == "utm") {
      # Enable guest tools
      services.spice-vdagentd.enable = true;
      services.qemuGuest.enable = true;

      # Pretend that we support OpenGL 3.3
      environment.sessionVariables = {
        MESA_GL_VERSION_OVERRIDE = "3.3";
        MESA_GLSL_VERSION_OVERRIDE = "330";
      };

      boot.initrd.availableKernelModules = [
        "9p"
        "9pnet_virtio"
      ];
      boot.kernelModules = [
        "9p"
        "9pnet_virtio"
      ];

      systemd.tmpfiles.rules = [
        "d /mnt/utm 777 root root -"
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

    (lib.mkIf (hypervisor == "vmware") {
      # Enable VMWare guest tools
      virtualisation.vmware.guest.enable = true;

      # Workaround for broken DNS
      networking.networkmanager.insertNameservers = [
        "8.8.8.8"
        "1.1.1.1"
      ];

      systemd.tmpfiles.rules = [
        "d /mnt/hgfs 0755 root root -"
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
}
