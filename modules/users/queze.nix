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

    # Set git identity
    programs.git.config = {
      user.name = "queze1";
      user.email = "52340127+queze1@users.noreply.github.com";
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
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

      ".copilot"

      # Other
      "Coding"
      "etc/nixos"
      "cs3231"
    ];
  };
}
