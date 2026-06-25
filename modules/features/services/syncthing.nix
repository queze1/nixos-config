{
  flake.nixosModules.syncthing = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.syncthing;
    userHome = config.users.users.${cfg.user}.home;
    isHomeUser = lib.hasPrefix "/home/" userHome;

    # Check if a path is inside the user's home folder
    # Exclude users with home directories which don't start with /home (e.g. system users)
    inHome = path: isHomeUser && lib.hasPrefix "${userHome}/" path;

    # Convert absolute paths to relative paths
    toRelative = path: lib.removePrefix "${userHome}/" path;
  in {
    services.syncthing.enable = true;

    # If the paths are outside of the /home/ directory (like /var/lib/syncthing), preserve them at the system level
    my.preservation.extraDirectories =
      (lib.optional (!inHome cfg.dataDir) {
        directory = cfg.dataDir;
        user = cfg.user;
        group = cfg.group;
        mode = "0700";
      })
      ++ (lib.optional (!inHome cfg.configDir) {
        directory = cfg.configDir;
        user = cfg.user;
        group = cfg.group;
        mode = "0700";
      });

    # If the paths are inside the /home/ directory, preserve them under the user's home
    my.preservation.extraUserDirectories =
      (lib.optional (inHome cfg.dataDir) (toRelative cfg.dataDir))
      ++ (lib.optional (inHome cfg.configDir) (toRelative cfg.configDir));
  };
}
