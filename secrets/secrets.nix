let
  sshKeys = import ../ssh-keys.nix;
in {
  "queze-password.age" = {
    publicKeys = [sshKeys.ableArcher];
    armor = true;
  };
  "queze-ssh-config.age" = {
    publicKeys = [sshKeys.ableArcher];
    armor = true;
  };
  "tavily-api-key.age" = {
    publicKeys = [sshKeys.ableArcher];
    armor = true;
  };
}
