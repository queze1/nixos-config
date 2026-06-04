let
  username = "queze";
in
{
  flake.nixosModules.${username} =
    { config, ... }:
    {
      users.users.${username} = {
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets."${username}-password".path;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };

      home-manager.users.${username} = {
        home.username = username;
        home.homeDirectory = "/home/${username}";
        home.stateVersion = "25.11";
        programs.home-manager.enable = true;

        # Sync with phone home server
        services.syncthing = {
          enable = true;
          settings = {
            devices = {
              "poco-x3-pro" = {
                id = "CGN4GSA-JX3232W-WM5XXI6-RKU3W6F-RVAZH7N-YPOCAF3-52SRDUO-HHRFFQI";
                addresses = [
                  "tcp://100.102.46.127:22000"
                ];
              };
            };
            folders = {
              "SillyTavern Data" = {
                id = "nicrf-adfwa";
                path = "/mnt/utm/Apps/SillyTavern-Launcher/SillyTavern/data/default-user";
                devices = [ "poco-x3-pro" ];
              };
              "Music" = {
                id = "ft74r-2c4sc";
                path = "/mnt/utm/Music";
                devices = [ "poco-x3-pro" ];
              };
            };
          };
        };
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
          ".cache/keepassxc" # save last opened database
          ".cache/noctalia" # stop showing welcome message
          ".config/keepassxc"
          ".config/obsidian"
          ".config/vesktop"
          ".local/share/direnv" # preserve direnv allow
          ".local/share/fish" # preserve fish command history
          ".local/share/nvf" # preserve nvim plugin state
          ".local/state/lazygit" # stop showing welcome message
          ".local/state/nix" # preserve nix repl history and others
          ".local/state/nvf" # preserve nvim state
          ".local/state/wireplumber"
          ".local/state/syncthing"

          ".copilot"
          ".mozilla"

          # User directories
          "Desktop"
          "Documents"
          "Downloads"
          "Music"
          "Videos"

          # Other
          "Coding"
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
}
