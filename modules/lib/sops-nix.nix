{inputs, ...}: {
  flake.nixosModules.sops-nix = {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops.defaultSopsFile = "${inputs.secrets}/secrets/secrets.yaml";
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    sops.age.generateKey = true;

    my.preservation.extraDirectories = ["/var/lib/sops-nix"];
    my.preservation.extraUserDirectories = [".config/sops/age"];
  };
}
