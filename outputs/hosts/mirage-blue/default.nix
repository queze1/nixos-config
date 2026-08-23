{
  inputs,
  self,
  ...
}: let
  hostname = "mirage-blue";
in {
  # 512mb Oracle Cloud instance
  flake.nixosModules.mirageBlueConfiguration = {pkgs, ...}: {
    imports = [
      self.nixosModules.mirageBase
    ];

    my.caddy = {
      enable = true;
      cloudflareDns.enable = true;
    };
    my.ddns.enable = true;
    my.tailscaleAuth.enable = true;

    # Hosted services
    my.apps.beszel-hub.enable = true;

    # Backups
    my.restic = {
      enable = true;
      backups.backblaze-b2 = {
        user = "root";
        backupPrepareCommand = ''
          if ${pkgs.systemd}/bin/systemctl is-active --quiet beszel-hub.service; then
            touch /run/restic-backups-backblaze-b2/beszel-hub-was-active
            ${pkgs.systemd}/bin/systemctl stop beszel-hub.service
          fi
        '';
        backupCleanupCommand = ''
          if [ -e /run/restic-backups-backblaze-b2/beszel-hub-was-active ]; then
            ${pkgs.systemd}/bin/systemctl start beszel-hub.service
            rm -f /run/restic-backups-backblaze-b2/beszel-hub-was-active
          fi
        '';
        timerConfig = {
          OnCalendar = "daily";
          RandomizedDelaySec = "4h";
          Persistent = true;
        };
      };
    };

    networking.hostName = hostname;
  };

  flake.nixosConfigurations.${hostname} = self.factory.mkNixosSystem {
    nixpkgs = inputs.nixpkgs-stable;
    system = "x86_64-linux";
    modules = [
      self.nixosModules.mirageBlueConfiguration
      self.nixosModules.mirageBlueHardware
    ];
  };
}
