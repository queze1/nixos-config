{ inputs, self, ... }:
let
  username = "queze";
in
{
  flake.nixosModules.${username} =
    { config, ... }:
    {
      age.secrets."${username}-password".file = "${self}/secrets/${username}-password.age";

      users.users.${username} = {
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets."${username}-password".path;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };

      preservation.preserveAt."/persistent".users.${username} = {
        commonMountOptions = [
          "x-gvfs-hide"
        ];
        directories = [
          {
            directory = ".ssh";
            mode = "0700";
          }
          ".config/syncthing"
          ".copilot"
          ".local/share/direnv"
          ".local/share/fish"
          ".local/state/nix"
          ".local/state/nvim"
          ".local/state/wireplumber"
          ".mozilla"

          # User directories
          "Coding"
          "Desktop"
          "Documents"
          "Downloads"
          "Music"
          "Videos"
          "etc/nixos"
        ];
      };

      # Harmless if preservation is disabled
      # By default, missing parent directories are always created with ownership
      # `root:root` and mode `0755`, as described in {manpage}`tmpfiles.d(5)`.
      # tmpfiles is the recommended way of fixing this
      systemd.tmpfiles.settings.preservation = {
        "/home/${username}/.config".d = {
          user = username;
          group = "users";
          mode = "0755";
        };
        "/home/${username}/.local".d = {
          user = username;
          group = "users";
          mode = "0755";
        };
        "/home/${username}/.local/share".d = {
          user = username;
          group = "users";
          mode = "0755";
        };
        "/home/${username}/.local/state".d = {
          user = username;
          group = "users";
          mode = "0755";
        };
      };
    };

  flake.homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
    home.username = username;
    home.homeDirectory = "/home/${username}";

    home.stateVersion = "25.11";
    programs.home-manager.enable = true;
  };
}
