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
    };

    my.preservation.extraUserDirectories = [
      ".cache/keepassxc" # save last opened database
      ".cache/noctalia" # stop showing welcome message
      ".config/calibre"
      ".config/github-copilot" # preserve copilot.nvim token
      ".config/keepassxc"
      ".config/obsidian"
      ".config/vesktop"
      ".local/share/direnv" # preserve direnv allow
      ".local/share/devenv"
      ".local/share/fish" # preserve fish command history
      ".local/share/nvf" # preserve nvim plugin state
      ".local/share/zoxide"
      ".local/state/lazygit" # stop showing welcome message
      ".local/state/nix" # preserve nix repl history and others
      ".local/state/nvf" # preserve nvim state
      ".local/state/wireplumber"

      ".copilot"
      ".mozilla"

      # Other
      "Coding"
      "etc/nixos"
      "cs3231"
    ];
  };
}
