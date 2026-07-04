{self, ...}: let
  username = "queze";
in {
  flake.nixosModules.${username} = {
    imports = [
      # Activate Home Manager for this user
      (self.factory.homeConfiguration {inherit username;})
    ];

    # Required for devenv
    nix.settings = {
      trusted-users = ["${username}"];
    };

    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      initialHashedPassword = "$y$j9T$.1ZgO3bCug1Pmc3BId1xD0$Cl9wLx9Ur24CdX6klxO9A4ErtEnRnz0j5wYjnFZRZm.";
      hashedPasswordFile = "/persistent/passwd"; # sudo sh -c 'mkpasswd -m yescrypt > /persistent/passwd'
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
