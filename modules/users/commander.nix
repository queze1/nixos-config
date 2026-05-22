let
  username = "commander";
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

        home-manager.users.${username} = {
          home.username = username;
          home.homeDirectory = "/home/${username}";
          home.stateVersion = "25.11";
          programs.home-manager.enable = true;
        };

        openssh.authorizedKeys.keys = [
          # able-archer
          # TODO: Store SSH keys as variables in a file to avoid magic strings
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINC3vA0PnFXyFRgitP7U8PL+SlTvqvE6eY73rpW5Rj4y"
        ];
      };
    };
}
