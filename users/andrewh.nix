{ self, config, ... }:
{
  age.secrets.andrewh-password.file = "${self}/secrets/andrewh-password.age";

  users.users.andrewh = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.andrewh-password.path;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
}
