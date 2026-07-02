{inputs, ...}: let
  username = "commander";
  sshKeys = import "${inputs.secrets}/ssh-keys.nix";
in {
  flake.nixosModules.${username} = {
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];

      initialHashedPassword = "$y$j9T$nS.BeshWf5D0S1Y0vwHcL/$d3284XHsMtupMdPZDZFtDEyKR/GVEWHkEE.z2T5R4i8";
      openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];
    };
  };
}
