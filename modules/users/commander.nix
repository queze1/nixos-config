{ inputs, ... }:
let
  username = "commander";
in
{
  flake.nixosModules.${username} =
    { config, ... }:
    {
      # TODO: Make this user loginable with SSH only
      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };
    };

  flake.homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
    home.username = username;
    home.homeDirectory = "/home/${username}";

    home.stateVersion = "25.11";
    programs.home-manager.enable = true;
  };
}
