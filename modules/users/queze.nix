{ self, ... }:
let
  username = "queze";
in
{
  flake.nixosModules.quezeUser =
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

      persistence = {
        users.${username} = {
          commonMountOptions = [
            "x-gvfs-hide"
          ];
          directories = [
            {
              directory = ".ssh";
              mode = "0700";
            }
            ".config/syncthing"
            ".local/share/direnv"
            ".local/share/fish"
            ".local/state/nix"
            ".local/state/nvim"
            ".local/state/wireplumber"
            ".mozilla"
          ];
        };
        root = {
          home = "/root";
          directories = [
            {
              directory = ".ssh";
              mode = "0700";
            }
          ];
        };
      };

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
}
