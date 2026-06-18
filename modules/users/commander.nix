{self, ...}: let
  username = "commander";
  sshKeys = import "${self}/ssh-keys.nix";
in {
  flake.nixosModules.${username} = {
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      openssh.authorizedKeys.keys = [sshKeys.ableArcher];
    };
  };
}
