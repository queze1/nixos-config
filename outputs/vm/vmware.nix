{self, ...}: let
  sharedDirPath = "/mnt/hgfs";
in {
  flake.nixosModules.vmware = {
    virtualisation.vmware.guest.enable = true;

    # DNS workaround
    networking.networkmanager.insertNameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  flake.factory.vmwareMountSharedDir = {username}: {config, ...}: let
    uid = config.users.users.${username}.uid;
  in {
    # Set correct permissions
    systemd.tmpfiles.rules = [
      "d ${sharedDirPath} 755 ${username} users -"
    ];

    systemd.mounts = [
      {
        what = ".host:/";
        where = "${sharedDirPath}";
        type = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
        options = "allow_other,uid=${uid}";
        wantedBy = ["multi-user.target"];
        after = ["sys-fs-fuse-connections.mount"];
      }
    ];
  };

  flake.nixosModules.vmwareHMIntegration = {
    home-manager.sharedModules = [
      self.homeModules.vmware
    ];
  };

  flake.homeModules.vmware = {
    imports = [
      (self.factory.setXdgUserDirs {homeDir = "${sharedDirPath}";})
    ];

    # https://gitlab.freedesktop.org/pipewire/pipewire/-/wikis/Troubleshooting#stuttering-audio-in-virtual-machine
    xdg.configFile."wireplumber/wireplumber.conf.d/50-alsa-config.conf".text = ''
      monitor.alsa.rules = [
        {
          matches =[
            # This matches the value of the 'node.name' property of the node.
            {
              node.name = "~alsa_output.*"
            }
          ]
          actions = {
            # Apply all the desired node specific settings here.
            update-props = {
              api.alsa.period-size   = 1024
              api.alsa.headroom      = 8192
              session.suspend-timeout-seconds = 86400  # disable suspend
              api.alsa.start-delay   = 1024
            }
          }
        }
      ]
    '';
  };
}
