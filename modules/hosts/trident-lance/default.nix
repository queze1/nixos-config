{
  inputs,
  self,
  ...
}: let
  hostname = "trident-lance";
  sshKeys = import "${self}/ssh-keys.nix";
in {
  # Configuration for testing on cloud (CURRENTLY BROKEN)
  flake.nixosModules.tridentLanceConfiguration = {
    config,
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      self.nixModules.myOptions
      self.nixosModules.sharedModules
      "${modulesPath}/virtualisation/digital-ocean-config.nix"

      # Basic libraries
      (self.factory.diskoSimpleEfi
        {device = "/dev/vda";})
      self.nixosModules.sopsNix

      # Nix-related
      self.nixosModules.setupAccessTokens

      # Services
      self.nixosModules.comin
      self.nixosModules.openssh
      self.nixosModules.podmanContainers
      self.nixosModules.resticDefaults
      self.nixosModules.tailscale

      # Ingress & routing
      self.nixosModules.caddy
      self.nixosModules.cloudflared
      self.nixosModules.ddns
      self.nixosModules.tailscaleAuth

      # Self-hosted apps
      self.nixosModules.actual
      self.nixosModules.arkRpVisualisation
      self.nixosModules.musicStack
      self.nixosModules.pihole
      self.nixosModules.sillytavern
    ];

    # do not use DHCP, as DigitalOcean provisions IPs using cloud-init
    networking.useDHCP = lib.mkForce false;

    # Disables all modules that do not work with NixOS
    services.cloud-init = {
      enable = true;
      network.enable = true;
      settings = {
        datasource_list = [
          "ConfigDrive"
          "Digitalocean"
        ];
        datasource.ConfigDrive = {};
        datasource.Digitalocean = {};
        # Based on https://github.com/canonical/cloud-init/blob/main/config/cloud.cfg.tmpl
        cloud_init_modules = [
          "seed_random"
          "bootcmd"
          "write_files"
          "growpart"
          "resizefs"
          "set_hostname"
          "update_hostname"
          # Not support on NixOS
          #"update_etc_hosts"
          # throws error
          #"users-groups"
          # tries to edit /etc/ssh/sshd_config
          #"ssh"
          "set_password"
        ];
        cloud_config_modules = [
          "ssh-import-id"
          "keyboard"
          # doesn't work with nixos
          #"locale"
          "runcmd"
          "disable_ec2_metadata"
        ];
        ## The modules that run in the 'final' stage
        cloud_final_modules = [
          "write_files_deferred"
          "puppet"
          "chef"
          "ansible"
          "mcollective"
          "salt_minion"
          "reset_rmc"
          # install dotty agent fails
          #"scripts_vendor"
          "scripts_per_once"
          "scripts_per_boot"
          # /var/lib/cloud/scripts/per-instance/machine_id.sh has broken shebang
          #"scripts_per_instance"
          "scripts_user"
          "ssh_authkey_fingerprints"
          "keys_to_console"
          "install_hotplug"
          "phone_home"
          "final_message"
        ];
      };
    };

    # Allow SSH into root
    users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];

    # Automatically auth into Tailscale as a server
    sops.secrets.tailscale-auth-key = {};
    services.tailscale = {
      authKeyFile = config.sops.secrets.tailscale-auth-key.path;
    };

    # Set incrementing port numbers
    services.actual.settings.port = 8000;
    services.ark-rp-viz.port = 8001;
    services.metube.port = 8002;
    services.picard.port = 8003;
    services.pihole-web.ports = ["8004"];
    services.sillytavern.port = 8005;
    services.yubal.port = 8006;

    my.restic = {
      # Don't back up but allow restoring backups
      backups.backblaze-b2 = {
        timerConfig = null;
      };
      backups.local-server = {
        timerConfig = null;
      };
    };

    networking.hostName = hostname;
    system.stateVersion = "25.11";
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = [self.nixosModules.tridentLanceConfiguration];
  };
}
