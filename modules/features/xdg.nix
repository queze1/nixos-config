{
  flake.homeModules.xdgUserDirs =
    { config, lib, ... }:
    let
      cfg = config.host.hypervisor;
      basePath =
        if cfg.useForXDGUserDirs && cfg.sharedFolder != null then
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
      };
    };
}
