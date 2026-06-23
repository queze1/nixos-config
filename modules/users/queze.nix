let
  username = "queze";
in {
  flake.nixosModules.${username} = {
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      initialHashedPassword = "$y$j9T$.1ZgO3bCug1Pmc3BId1xD0$Cl9wLx9Ur24CdX6klxO9A4ErtEnRnz0j5wYjnFZRZm.";
      hashedPasswordFile = "/persistent/passwd"; # sudo sh -c 'mkpasswd -m yescrypt > /persistent/passwd'
    };

    # Add to trusted users for devenv
    nix.settings = {
      trusted-users = ["${username}"];
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
              devices = ["poco-x3-pro"];
            };
            "Music" = {
              id = "ft74r-2c4sc";
              path = "/mnt/utm/Music";
              devices = ["poco-x3-pro"];
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
        ".config/calibre"
        ".config/github-copilot" # preserve copilot.nvim token
        ".config/keepassxc"
        ".config/obsidian"
        ".config/vesktop"
        ".local/share/direnv" # preserve direnv allow
        ".local/share/fish" # preserve fish command history
        ".local/share/nvf" # preserve nvim plugin state
        ".local/state/lazygit" # stop showing welcome message
        ".local/state/nix" # preserve nix repl history and others
        ".local/state/nvf" # preserve nvim state
        ".local/state/syncthing"
        ".local/state/wireplumber"

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
        "cs3231"
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
