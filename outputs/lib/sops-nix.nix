{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.sopsNix = {config, ...}: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    # To generate a public age key from an SSH host key:
    # nix shell nixpkgs#ssh-to-age nixpkgs#age -c sh -c 'sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key | age-keygen -y'
    sops.age.sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/persistent/etc/ssh/ssh_host_ed25519_key"
    ];
    sops.defaultSopsFile = "${inputs.secrets}/secrets/${config.networking.hostName}.yaml";
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
