{self, ...}: {
  flake.nixosModules.nixbuild = {config, ...}: {
    imports = [self.nixosModules.nixbuildAsSubstituter];

    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "eu.nixbuild.net";
          system = config.nixpkgs.buildPlatform;
          maxJobs = 100;
          supportedFeatures = ["benchmark" "big-parallel"];
        }
      ];
    };
  };

  flake.nixosModules.nixbuildAsSubstituter = {config, ...}: {
    sops.secrets.nixbuild-private-key = {};

    programs.ssh.extraConfig = ''
      Host eu.nixbuild.net
      PubkeyAcceptedKeyTypes ssh-ed25519
      ServerAliveInterval 60
      IdentityFile ${config.sops.secrets.nixbuild-private-key.path}
    '';

    programs.ssh.knownHosts = {
      nixbuild = {
        hostNames = ["eu.nixbuild.net"];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
      };
    };

    nix.settings = {
      substituters = ["ssh://eu.nixbuild.net"];
      trusted-public-keys = ["nixbuild.net/DHZ6OD-1:0B9aZ9YuXT6XH7PyKDlzcKYj/SjwEw2VzBJEfq7tPMM="];
    };
  };
}
