{self, ...}: let
  sharedDirPath = "/mnt/utm";
in {
  flake.nixosModules.utm = {
    services.spice-vdagentd.enable = true;
    services.qemuGuest.enable = true;
  };

  flake.factory.utmMountSharedDir = {username}: {config, ...}: let
    uid =
      if config.users.users.${username}.uid == null
      then 1000
      else config.users.users.${username}.uid;
  in {
    # Load required kernel modules
    boot.initrd.availableKernelModules = [
      "9p"
      "9pnet_virtio"
    ];
    boot.kernelModules = [
      "9p"
      "9pnet_virtio"
    ];

    # Set correct permissions
    systemd.tmpfiles.rules = [
      "d ${sharedDirPath} 755 ${username} users -"
    ];

    fileSystems = {
      ${sharedDirPath} = {
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
          "uid=${toString uid}"
          "gid=100"

          # Set maximum message size to 512 KiB
          "msize=524288"
        ];
      };
    };
  };

  flake.nixosModules.utmHMIntegration = {
    home-manager.sharedModules = [
      self.homeModules.utm
    ];
  };

  flake.homeModules.utm = {
    imports = [
      (self.factory.setXdgUserDirs {homeDir = "${sharedDirPath}";})
    ];

    # Fix PDFs on UTM
    programs.firefox.profiles.default.settings."gfx.canvas.accelerated" = false;
  };
}
