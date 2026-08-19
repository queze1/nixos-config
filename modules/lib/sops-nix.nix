{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.my.sops;
in {
  imports = [inputs.sops-nix.nixosModules.sops];

  options.my.sops = {
    enable = lib.mkEnableOption "sops-nix";
    homeManager.enable = lib.mkEnableOption "sops-nix Home Manager integration";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      sops = {
        # To generate a public age key from an SSH host key:
        # nix shell nixpkgs#ssh-to-age nixpkgs#age -c sh -c 'sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key | age-keygen -y'
        age.sshKeyPaths = [
          "/etc/ssh/ssh_host_ed25519_key"
          "/persistent/etc/ssh/ssh_host_ed25519_key"
        ];
        defaultSopsFile = "${inputs.secrets}/secrets/${config.networking.hostName}.yaml";
      };
    })
    (lib.mkIf cfg.homeManager.enable {
      assertions = [
        {
          assertion = cfg.enable && config.my.homeManager.enable;
          message = "my.sops.homeManager.enable requires my.sops.enable and my.homeManager.enable.";
        }
      ];

      home-manager.sharedModules = [
        ({osConfig, ...}: {
          imports = [inputs.sops-nix.homeManagerModules.sops];

          sops.defaultSopsFile = "${inputs.secrets}/secrets/${osConfig.networking.hostName}-home.yaml";
          sops.age.keyFile = ".config/sops/age/keys.txt";
        })
      ];

      my.preservation.extraUserDirectories = [".config/sops/age"];
    })
  ];
}
