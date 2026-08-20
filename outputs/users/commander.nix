{self, ...}: let
  username = "commander";
  sshKeys = import "${self}/ssh-keys.nix";
in {
  flake.nixosModules.${username} = {
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];

      # Fallback in case internet breaks and you need physical access
      hashedPassword = "$y$j9T$nS.BeshWf5D0S1Y0vwHcL/$d3284XHsMtupMdPZDZFtDEyKR/GVEWHkEE.z2T5R4i8";
      openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];
    };
  };
}
