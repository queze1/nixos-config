{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  myCfg = config.my.apps._4get;
  package = self.packages.${pkgs.stdenv.hostPlatform.system}._4get;

  user = "4get";
  group = "4get";
  dataDir = "/var/lib/4get";
  webRoot = "${dataDir}/www";
  phpPackage = pkgs.php.withExtensions (
    {
      enabled,
      all,
    }:
      enabled ++ [all.apcu all.imagick]
  );
in {
  options.my.apps._4get = {
    enable = lib.mkEnableOption "4get";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "4get.osipol.uk";
      description = "Domain to host 4get on.";
    };
  };

  config = lib.mkIf myCfg.enable {
    services.phpfpm.pools._4get = {
      inherit user group phpPackage;
      settings = {
        "listen.owner" = config.services.caddy.user;
        "listen.group" = config.services.caddy.group;
        "listen.mode" = "0660";
        "pm" = "dynamic";
        "pm.max_children" = 10;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 3;
      };
    };

    # Set up the 4get directory
    systemd.services.phpfpm-_4get = {
      path = [pkgs.coreutils pkgs.imagemagick];
      preStart = ''
        chown ${user}:${group} ${dataDir}
        if [ ! -e ${dataDir}/package ] || [ "$(cat ${dataDir}/package)" != ${package} ]; then
          rm -rf ${webRoot}.new
          mkdir -p ${webRoot}.new
          cp -a ${package}/share/4get/. ${webRoot}.new/

          if [ -e ${webRoot}/data/config.php ]; then
            mkdir -p ${webRoot}.new/data
            cp -a ${webRoot}/data/config.php ${webRoot}.new/data/config.php
          fi

          if [ -d ${webRoot}/icons ]; then
            rm -rf ${webRoot}.new/icons
            mv ${webRoot}/icons ${webRoot}.new/icons
          fi

          mkdir -p ${webRoot}.new/icons
          chmod -R u=rwX,g=rX,o= ${webRoot}.new
          chmod -R u=rwX,g=rX,o= ${webRoot}.new/icons
          rm -rf ${webRoot}
          mv ${webRoot}.new ${webRoot}
          chown -R ${user}:${group} ${webRoot}
          printf %s ${package} > ${dataDir}/package
        fi
      '';
      serviceConfig = {
        StateDirectory = "4get";
        StateDirectoryMode = "0750";
      };
    };

    # Preserve 4get data
    my.preservation.extraDirectories = [
      {
        directory = dataDir;
        inherit user group;
        mode = "0750";
      }
    ];

    # Create a system user for 4get
    users.users.${user} = {
      isSystemUser = true;
      inherit group;
      home = dataDir;
    };
    users.groups.${group} = {};

    # Give Caddy access to 4get
    users.users.${config.services.caddy.user}.extraGroups = [group];

    # Reverse proxy
    services.caddy.virtualHosts.${myCfg.domain}.extraConfig = ''
      import cloudflare_dns
      root * ${webRoot}
      file_server
      php_fastcgi unix/${config.services.phpfpm.pools._4get.socket} {
        index index.php
      }
      redir /{path}.php{query} 301
      try_files {path} {path}.php
    '';
    services.ddclient.domains = [myCfg.domain];
  };
}
