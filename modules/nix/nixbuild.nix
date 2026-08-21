{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixbuild;
in {
  options.my.nixbuild.enable = lib.mkEnableOption "nixbuild";

  config = lib.mkIf cfg.enable {
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

    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "eu.nixbuild.net";
          system = pkgs.stdenv.hostPlatform.system;
          maxJobs = 100;
          supportedFeatures = ["benchmark" "big-parallel"];
        }
      ];
    };
  };
}
