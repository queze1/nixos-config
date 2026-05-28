{ self, ... }:
let
  sshKeys = import "${self}/ssh-keys.nix";
in
{
  "queze-password.age" = {
    publicKeys = sshKeys.allKeys;
    armor = true;
  };
  "tavily-api-key.age" = {
    publicKeys = sshKeys.allKeys;
    armor = true;
  };
}
