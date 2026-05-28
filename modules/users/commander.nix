{ self, ... }:
let
  username = "commander";
  sshKeys = import "${self}/ssh-keys.nix";
in
{
  flake.nixosModules.${username} =
    { config, ... }:
    {
      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        openssh.authorizedKeys.keys = sshKeys.allKeys;
      };

      home-manager.users.${username} = {
        home.username = username;
        home.homeDirectory = "/home/${username}";
        home.stateVersion = "25.11";
        programs.home-manager.enable = true;
      };
    };
}
