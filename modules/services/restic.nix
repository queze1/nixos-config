{
  pkgs,
  inputs,
  config,
  lib,
  options,
  ...
}: let
  cfg = config.my.restic;
  toSubpath = p: lib.path.removePrefix /. (/. + p);
  backupSubmodule = options.services.restic.backups.type.nestedTypes.elemType.getSubModules;

  combineCommands = commands: let
    nonEmptyCommands = lib.filter (command: command != null && command != "") commands;
  in
    if nonEmptyCommands == []
    then null
    else lib.concatStringsSep "\n" nonEmptyCommands;

  serviceRestartHooks = services: {
    prepare = lib.concatStringsSep "\n" (lib.imap0 (index: service: ''
        if ${lib.getExe' pkgs.systemd "systemctl"} is-active --quiet ${lib.escapeShellArg service}; then
          touch "$RUNTIME_DIRECTORY/restart-service-${toString index}"
          ${lib.getExe' pkgs.systemd "systemctl"} stop ${lib.escapeShellArg service}
        fi
      '')
      services);
    cleanup = lib.concatStringsSep "\n" (lib.imap0 (index: service: ''
        if [ -e "$RUNTIME_DIRECTORY/restart-service-${toString index}" ]; then
          ${lib.getExe' pkgs.systemd "systemctl"} start ${lib.escapeShellArg service}
          rm -f "$RUNTIME_DIRECTORY/restart-service-${toString index}"
        fi
      '')
      services);
  };

  # Wrapper that cds into the latest snapshot before executing restic backup
  resticWrapper = pkgs.writeShellScriptBin "restic" ''
    set -e
    if [ "''${1:-}" = "backup" ]; then
      latest=$(${lib.getExe' pkgs.coreutils "ls"} -1 ${lib.escapeShellArg cfg.snapshotsDir} 2>/dev/null \
        | ${lib.getExe' pkgs.coreutils "sort"} | ${lib.getExe' pkgs.coreutils "tail"} -n1)
      if [ -n "$latest" ]; then
        cd "${cfg.snapshotsDir}/$latest"
      fi
      echo "Working directory: $(${lib.getExe' pkgs.coreutils "pwd"})"
    fi
    exec ${lib.getExe pkgs.restic} "$@"
  '';

  # Wrapper which runs restic with the environment of a different hostname
  remoteResticWrapper = pkgs.writeShellScriptBin "restic-remote" ''
    set -eu

    if [ "$#" -lt 3 ]; then
      echo "Usage: restic-remote <hostname> <backup-target> <restic-command> [arguments...]" >&2
      exit 2
    fi

    hostname="$1"
    backupTarget="$2"
    shift 2

    set -a
    source <(
      ${lib.getExe pkgs.sops} --decrypt \
        --extract "[\"restic-$backupTarget-env\"]" \
        "${inputs.secrets}/secrets/$hostname.yaml"
    )
    set +a

    exec ${lib.getExe pkgs.restic} "$@"
  '';

  # Define a submodule which sets pre-evaluation defaults
  myBackupSubmodule = let
    systemConfig = config;
  in
    lib.types.submodule [
      (
        {
          name,
          config,
          ...
        }: {
          imports = backupSubmodule;

          options.restartServices = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Systemd services to stop before the backup and restart afterward if they were active.";
          };

          config = {
            initialize = lib.mkDefault true;
            environmentFile = lib.mkDefault systemConfig.sops.secrets."restic-${name}-env".path;
            package = lib.mkIf (cfg.snapshotsDir != null) (lib.mkDefault resticWrapper);
            user = lib.mkDefault (
              if config.restartServices != []
              then "root"
              else "restic-${name}"
            );
          };
        }
      )
    ];
in {
  options.my.restic = {
    enable = lib.mkEnableOption "Restic defaults";
    createRemoteWrapper = lib.mkEnableOption "the restic-remote wrapper";
    backups = lib.mkOption {
      type = lib.types.attrsOf myBackupSubmodule;
      default = {};
      description = "Periodic backups to create with Restic.";
    };
    extraPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        Which paths to back up. This applies to all backup targets.
      '';
    };
    extraExclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        Which paths to exclude. This applies to all backup targets.
      '';
    };
    snapshotsDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        If set, paths are backed up relative to the newest (lexicographically last) directory found in this directory.
        Every path is turned into a subpath and a wrapper is generated that `cd`s into that directory before restic runs.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions =
      [
        {
          assertion = cfg.extraPaths == [] || cfg.backups != {};
          message = "my.restic.extraPaths is set, but no my.restic.backups are defined.";
        }
      ]
      ++ lib.mapAttrsToList (name: backup: {
        assertion = backup.restartServices == [] || backup.user == "root";
        message = "my.restic.backups.${name}.restartServices requires user = \"root\".";
      })
      cfg.backups;

    # For every backup, define an environment file secret
    sops.secrets =
      lib.concatMapAttrs (name: _: {
        "restic-${name}-env" = {};
      })
      cfg.backups;

    services.restic.backups = lib.mapAttrs (_: backup: let
      restartHooks = serviceRestartHooks backup.restartServices;
    in
      (builtins.removeAttrs backup ["restartServices"])
      // {
        backupPrepareCommand = combineCommands [backup.backupPrepareCommand restartHooks.prepare];
        backupCleanupCommand = combineCommands [restartHooks.cleanup backup.backupCleanupCommand];
        paths = let
          allPaths = backup.paths ++ cfg.extraPaths;
        in
          if cfg.snapshotsDir != null
          then map toSubpath allPaths
          else allPaths;
        exclude = let
          allExclude = backup.exclude ++ cfg.extraExclude;
        in
          if cfg.snapshotsDir != null
          then map toSubpath allExclude
          else allExclude;
      })
    cfg.backups;

    # Give each restic service ambient capacities instead of running as root
    # https://restic.readthedocs.io/en/latest/080_examples.html#backing-up-your-system-without-running-restic-as-root
    systemd.services = lib.mapAttrs' (name: backup:
      lib.nameValuePair "restic-backups-${name}" {
        serviceConfig = lib.mkIf (backup.user != "root") {
          DynamicUser = true;
          AmbientCapabilities = "CAP_DAC_READ_SEARCH";
          CapabilityBoundingSet = "CAP_DAC_READ_SEARCH";
        };
      })
    cfg.backups;

    environment.systemPackages = lib.optional cfg.createRemoteWrapper remoteResticWrapper;
  };
}
