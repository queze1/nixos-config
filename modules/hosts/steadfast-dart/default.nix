{
  inputs,
  self,
  ...
}: let
  hostname = "steadfast-dart";
in {
  # Newer home server
  flake.nixosModules.steadfastDartConfiguration = {pkgs, ...}: {
    imports = [
      self.nixosModules.steadfastBase

      self.nixosModules.podmanContainers

      # Ingress & routing
      self.nixosModules.caddy
      self.nixosModules.caddyCloudflareDNS
      self.nixosModules.cloudflared
      self.nixosModules.ddns
      self.nixosModules.tailscaleAuth

      # Self-hosted apps
      self.nixosModules.actual
      self.nixosModules.arkRpVisualisation
      self.nixosModules.forgejo
      self.nixosModules.github2forgejo
      self.nixosModules.musicStack
      self.nixosModules.pihole
      self.nixosModules.resticServer
      self.nixosModules.sillytavern
      self.nixosModules.vaultwarden
    ];

    environment.etc = {
      "test".text = "testing.";
    };

    # To deploy to VPS without building on target
    # colmena apply --nix-option tarball-ttl 0 --config github:queze1/nixos-config --no-build-on-target --on @cloud
    environment.systemPackages = [
      inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena
    ];

    # Set incrementing port numbers
    my.apps.actual.port = 8000;
    my.apps.ark-rp-viz.port = 8001;
    my.apps.metube.port = 8002;
    my.apps.picard.port = 8003;
    my.apps.pihole.ports = ["8004"];
    my.apps.sillytavern.port = 8005;
    my.apps.vaultwarden.port = 8006;
    my.apps.yubal.port = 8007;

    my.restic = {
      snapshotsDir = "/persistent/snapshots";
      extraPaths = [
        "/etc/ssh"
        "/var/lib/nixos"
        "/var/lib/tailscale"
      ];
      backups.backblaze-b2 = {
        timerConfig = {
          OnCalendar = "daily";
          RandomizedDelaySec = "4h";
          Persistent = true;
        };
      };
      backups.local-server = {
        timerConfig = {
          OnCalendar = "hourly";
          RandomizedDelaySec = "15m";
          Persistent = true;
        };
      };
    };

    hardware.facter.reportPath = ./facter.json;
    networking.hostName = hostname;
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    pkgs = import inputs.nixpkgs-stable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    modules = [self.nixosModules.steadfastDartConfiguration];
  };
}
