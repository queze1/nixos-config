let
  sshKeys = import ../ssh-keys.nix;
in {
  "queze-ssh-config.age" = {
    publicKeys = sshKeys.ableArcherKeys;
    armor = true;
  };
  "tavily-api-key.age" = {
    publicKeys = sshKeys.ableArcherKeys;
    armor = true;
  };
  "tailscale-auth-key.age" = {
    publicKeys = sshKeys.allKeys;
    armor = true;
  };
}
