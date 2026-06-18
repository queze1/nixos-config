{self, ...}: let
  username = "commander";
  sshKeys = import "${self}/ssh-keys.nix";
in {
  flake.nixosModules.${username} = {config, ...}: {
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];

      hashedPasswordFile = config.age.secrets."${username}-password".path; # fallback in case SSH fails
      openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];
    };
  };
}
