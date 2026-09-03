{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.atticd;
  myCfg = config.my.apps.attic;

  format = pkgs.formats.toml {};

  checkedConfigFile =
    pkgs.runCommand "checked-attic-server.toml"
    {
      configFile = format.generate "server.toml" cfg.settings;
    }
    ''
      export ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64="$(${lib.getExe pkgs.openssl} genrsa -traditional 4096 | ${pkgs.coreutils}/bin/base64 -w0)"
      export ATTIC_SERVER_DATABASE_URL="sqlite://:memory:"
      ${lib.getExe cfg.package} --mode check-config -f $configFile
      cat <$configFile >$out
    '';

  atticadmShim = pkgs.writeShellScript "atticadm" ''
    if [ -n "$ATTICADM_PWD" ]; then
      cd "$ATTICADM_PWD"
      if [ "$?" != "0" ]; then
        >&2 echo "Warning: Failed to change directory to $ATTICADM_PWD"
      fi
    fi

    exec ${lib.getExe' cfg.package "atticadm"} -f ${checkedConfigFile} "$@"
  '';

  # Patch to remove DynamicUser from
  # https://github.com/NixOS/nixpkgs/blob/e5bdc4a41d4c072fe1e3787eaa0320a384741d44/nixos/modules/services/networking/atticd.nix
  myAtticadmWrapper = pkgs.writeShellScriptBin "atticd-atticadm" ''
    exec systemd-run \
      --quiet \
      --pipe \
      --pty \
      --same-dir \
      --wait \
      --collect \
      --service-type=exec \
      --property=EnvironmentFile=${cfg.environmentFile} \
      --property=User=${cfg.user} \
      --property=Environment=ATTICADM_PWD=$(pwd) \
      --working-directory / \
      -- \
      ${atticadmShim} "$@"
  '';

  # Script to create a public cache
  initialiseCache = pkgs.writeShellScript "initialise-attic-cache" ''
    set -euo pipefail

    token="$(${atticadmShim} make-token --sub "initialise cache" --validity "1h" --create-cache "cache")"
    ${lib.getExe pkgs.attic-client} login default "https://${myCfg.domain}" "$token"
    ${lib.getExe pkgs.attic-client} cache create cache --public
    touch ${myCfg.dataDir}/.cache-initialized
  '';
in {
  options.my.apps.attic = {
    enable = lib.mkEnableOption "Attic";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "attic.osipol.uk";
      description = "Domain to host Attic on.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to run Attic on.";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/atticd";
      description = "Path where Attic stores its data.";
    };
    useS3 = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use S3 as the storage backend.";
    };
  };

  config = lib.mkIf myCfg.enable {
    # Recommended for use in production
    services.postgresql = {
      enable = true;
      ensureDatabases = ["atticd"];
      ensureUsers = [
        {
          name = "atticd";
          ensureDBOwnership = true;
        }
      ];
    };

    services.atticd = {
      enable = true;
      environmentFile = config.sops.secrets.atticd-env.path;
      settings = {
        listen = "127.0.0.1:${toString myCfg.port}";
        allowed-hosts = [myCfg.domain];
        api-endpoint = "https://${myCfg.domain}/";
        database.url = "postgresql:///atticd?host=/run/postgresql";
        storage = lib.mkIf myCfg.useS3 {
          type = "s3";
          region = "auto";
          endpoint = "https://0f53fadc798c0583aac1c94b962f040a.r2.cloudflarestorage.com";
          bucket = "nix-binary-cache";
        };
      };
    };

    sops.secrets.atticd-env.restartUnits = ["atticd.service"];

    # Use a static user instead of dynamic user
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
    };
    users.groups.${cfg.group} = {};
    systemd.services.atticd.serviceConfig = {
      DynamicUser = lib.mkForce false;
      RemoveIPC = true;
    };

    # Apply patch to disable DynamicUser
    environment.systemPackages = [
      (lib.hiPrio myAtticadmWrapper)
    ];

    # Initialise a cache on startup
    systemd.services.initialise-attic-cache = {
      description = "Initialise Attic cache";
      after = ["atticd.service"];
      requires = ["atticd.service"];
      wantedBy = ["multi-user.target"];
      unitConfig.ConditionPathExists = "!${myCfg.dataDir}/.cache-initialized";
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = myCfg.dataDir;
        Environment = "HOME=${myCfg.dataDir}";
        EnvironmentFile = cfg.environmentFile;
        ExecStart = initialiseCache;
      };
    };

    # Preserve Attic data and Postgres
    my.preservation.extraDirectories = [
      {
        directory = myCfg.dataDir;
        user = "atticd";
        group = "atticd";
        mode = "0700";
      }
      {
        directory = config.services.postgresql.dataDir;
        user = "postgres";
        group = "postgres";
        mode = "0700";
      }
    ];

    # Reverse proxy
    services.caddy.virtualHosts.${myCfg.domain}.extraConfig = ''
      import cloudflare_dns
      reverse_proxy 127.0.0.1:${toString myCfg.port}
    '';
    services.ddclient.domains = [myCfg.domain];

    # Only allow Caddy to access this port
    my.caddy.firewalledPorts = [myCfg.port];
  };
}
