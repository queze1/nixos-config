{
  config,
  lib,
  ...
}: let
  cfg = config.my.users.queze;
  username = "queze";
in {
  options.my.users.${username}.enable = lib.mkEnableOption username;

  config = lib.mkIf cfg.enable {
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      initialHashedPassword = "$y$j9T$.1ZgO3bCug1Pmc3BId1xD0$Cl9wLx9Ur24CdX6klxO9A4ErtEnRnz0j5wYjnFZRZm.";
      hashedPasswordFile = "/persistent/passwd";
    };

    # Required for devenv
    nix.settings.trusted-users = [username];

    home-manager.users.${username} = {config, ...}: {
      programs.ssh = {
        enable = true;
        includes = [config.sops.secrets."${username}-ssh-config".path];
        enableDefaultConfig = false;
        settings."*" = {
          ForwardAgent = false;
          AddKeysToAgent = "no";
          Compression = false;
          UserKnownHostsFile = "~/.ssh/known_hosts";
        };
      };
      sops.secrets."${username}-ssh-config" = {};

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
