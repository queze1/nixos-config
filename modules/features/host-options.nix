{
  flake.nixosModules.hostOptions =
    {
      config,
      lib,
      ...
    }:
    {
      # Modules are responsible for setting their defaults accordingly
      options.host = {
        profile = lib.mkOption {
          type = lib.types.enum [
            "personalComputer"
            "homeServer"
          ];
          default = "personalComputer";
          description = "Set the host profile";
        };

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
    };

  flake.homeModules.configureXDGUserDirs =
    { config, ... }:
    let
      cfg = config.host.hypervisor;
      basePath =
        if cfg.useSharedFolderForDestinations && cfg.sharedFolder != null then
          cfg.sharedFolder
        else
          "${config.users.homeDirectory}";
    in
    {
      xdg.userDirs = {
        enable = true;
        createDirectories = true; # create if missing

        download = "${basePath}/Downloads";
        documents = "${basePath}/Documents";
        pictures = "${basePath}/Pictures";
        videos = "${basePath}/Videos";
        music = "${basePath}/Music";
        extraConfig = {
          XDG_OBSIDIAN_DIR = "${basePath}/Documents/obsidian";
          # Use home directory even if shared directory was prefered, to avoid overhead
          XDG_CODING_DIR = "${config.users.homeDirectory}/Coding";
        };
      };
    };
}
