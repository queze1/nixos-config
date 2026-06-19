let
  sshKeys = import ../ssh-keys.nix;
in {
  "queze-password.age" = {
    publicKeys = sshKeys.ableArcherKeys;
    armor = true;
  };
  "queze-ssh-config.age" = {
    publicKeys = sshKeys.ableArcherKeys;
    armor = true;
  };
  "tavily-api-key.age" = {
    publicKeys = sshKeys.ableArcherKeys;
    armor = true;
  };
  "commander-password.age" = {
    publicKeys = sshKeys.allKeys;
    armor = true;
  };
  "tailscale-auth-key.age" = {
    publicKeys = sshKeys.allKeys;
    armor = true;
  };
}
