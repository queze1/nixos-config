{
  flake.nixosModules.attic = {
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

      exec ${cfg.package}/bin/atticadm -f ${checkedConfigFile} "$@"
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
  in {
    options.my.apps.attic = {
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
    };

    config = {
      services.atticd = {
        enable = true;
        environmentFile = config.sops.secrets.atticd-env.path;
        settings = {
          listen = "127.0.0.1:${toString myCfg.port}";
          allowed-hosts = [myCfg.domain];
          api-endpoint = "https://${myCfg.domain}/";
          storage = {
            type = "local";
            path = "${myCfg.dataDir}/storage";
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

      # Preserve Attic data
      my.preservation.extraDirectories = [
        {
          directory = myCfg.dataDir;
          user = "atticd";
          group = "atticd";
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
  };
}
