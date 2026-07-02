{self, ...}: let
  username = "queze";
in {
  flake.nixosModules.${username} = {
    imports = [
      # Activate Home Manager for this user
      (self.factory.homeConfiguration {inherit username;})

      # Programs
      (self.factory.devenv {inherit username;})
    ];

    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      initialHashedPassword = "$y$j9T$.1ZgO3bCug1Pmc3BId1xD0$Cl9wLx9Ur24CdX6klxO9A4ErtEnRnz0j5wYjnFZRZm.";
      hashedPasswordFile = "/persistent/passwd"; # sudo sh -c 'mkpasswd -m yescrypt > /persistent/passwd'
    };

    home-manager.users.${username} = {
      imports = [
        self.homeModules.direnv
        self.homeModules.keepassxc
        self.homeModules.obsidian
      ];
    };

    my.preservation.extraUserDirectories = [
      ".local/state/nix" # preserve nix repl history and others
      ".local/state/wireplumber"

      ".copilot"

      # Other
      "Coding"
      "etc/nixos"
      "cs3231"
    ];
  };
}
