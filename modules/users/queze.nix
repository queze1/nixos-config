{ self, ... }:
{
  # TODO: Define Home Manager configuration for queze and import it from the NixOS module queze
  flake.nixosModules.queze =
    { config, ... }:
    {
      age.secrets.queze-password.file = "${self}/secrets/queze-password.age";

      users.users.queze = {
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets.queze-password.path;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };
    };
}
