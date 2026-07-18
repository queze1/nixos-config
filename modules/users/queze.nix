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

    # Required for devenv
    nix.settings = {
      trusted-users = ["${username}"];
    };

    home-manager.users.${username} = {config, ...}: {
      # Use secret SSH config
      sops.secrets."${username}-ssh-config" = {};
      programs.ssh = {
        enable = true;
        includes = [config.sops.secrets."${username}-ssh-config".path];
      };

      home.username = username;
      home.homeDirectory = "/home/${username}";
      home.stateVersion = "25.11";
      programs.home-manager.enable = true;
    };

    my.preservation.extraUserDirectories = [
      "Coding"
      "etc/nixos"
      "cs3231"
    ];
  };
}
