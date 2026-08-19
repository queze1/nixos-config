{
  config,
  lib,
  ...
}: let
  cfg = config.my.utm;
  sharedDirPath = "/mnt/utm";
  uid =
    if config.users.users.${cfg.username}.uid == null
    then 1000
    else config.users.users.${cfg.username}.uid;
in {
  options.my.utm = {
    enable = lib.mkEnableOption "UTM guest integration";
    homeManager.enable = lib.mkEnableOption "UTM Home Manager integration";
    username = lib.mkOption {
      type = lib.types.str;
      description = "User that owns the shared UTM directory.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.spice-vdagentd.enable = true;
      services.qemuGuest.enable = true;

      boot.initrd.availableKernelModules = [
        "9p"
        "9pnet_virtio"
      ];
      boot.kernelModules = [
        "9p"
        "9pnet_virtio"
      ];

      systemd.tmpfiles.rules = [
        "d ${sharedDirPath} 755 ${cfg.username} users -"
      ];

      fileSystems.${sharedDirPath} = {
        device = "share";
        fsType = "9p";
        options = [
          "trans=virtio"
          "version=9p2000.L"
          "rw"
          "_netdev"
          "nofail"
          "access=client"
          "uid=${toString uid}"
          "gid=100"
          "msize=524288"
        ];
      };
    })

    (lib.mkIf cfg.homeManager.enable {
      assertions = [
        {
          assertion = cfg.enable && config.my.homeManager.enable;
          message = "my.utm.homeManager.enable requires my.utm.enable and my.homeManager.enable.";
        }
      ];

      home-manager.sharedModules = [
        {
          xdg.userDirs = {
            enable = true;
            createDirectories = true;
            setSessionVariables = false;
            download = "${sharedDirPath}/Downloads";
            documents = "${sharedDirPath}/Documents";
            pictures = "${sharedDirPath}/Pictures";
            videos = "${sharedDirPath}/Videos";
            music = "${sharedDirPath}/Music";
          };

          # Fix PDF rendering
          programs.firefox.profiles.default.settings."gfx.canvas.accelerated" = false;
        }
      ];
    })
  ];
}
