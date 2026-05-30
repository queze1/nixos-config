let
  sshKeys = import ../ssh-keys.nix;
in
{
  "queze-password.age" = {
    publicKeys = sshKeys.allKeys;
    armor = true;
  };
  "queze-ssh-config.age" = {
    publicKeys = sshKeys.allKeys;
    armor = true;
  };
  "tavily-api-key.age" = {
    publicKeys = sshKeys.allKeys;
    armor = true;
  };
}
