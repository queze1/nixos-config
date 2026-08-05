{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.sopsNix = {config, ...}: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops.age.sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/persistent/etc/ssh/ssh_host_ed25519_key"
    ];
    sops.defaultSopsFile = "${inputs.secrets}/secrets/${config.networking.hostName}.yaml";
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    sops.age.generateKey = true;

    my.preservation.extraDirectories = ["/var/lib/sops-nix"];

    # sops-nix runs as an activation script, make activation wait for initrd-preservation.target
    boot.initrd.systemd.services.initrd-nixos-activation = {
      after = ["initrd-preservation.target"];
      wants = ["initrd-preservation.target"];
    };
  };

  flake.nixosModules.sopsNixWithHM = {
    home-manager.sharedModules = [
      self.homeModules.sopsNix
    ];

    my.preservation.extraUserDirectories = [".config/sops/age"];
  };

  flake.homeModules.sopsNix = {osConfig, ...}: {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
    ];

    sops.defaultSopsFile = "${inputs.secrets}/secrets/${osConfig.networking.hostName}-home.yaml";
    sops.age.keyFile = ".config/sops/age/keys.txt";
  };
}
