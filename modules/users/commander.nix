{
  config,
  lib,
  self,
  ...
}: let
  cfg = config.my.users.commander;
  username = "commander";
  sshKeys = import "${self}/ssh-keys.nix";
in {
  options.my.users.${username}.enable = lib.mkEnableOption username;

  config = lib.mkIf cfg.enable {
    users.users.${username} = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      # Fallback in case SSH dies
      hashedPassword = "$y$j9T$nS.BeshWf5D0S1Y0vwHcL/$d3284XHsMtupMdPZDZFtDEyKR/GVEWHkEE.z2T5R4i8";
      openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];
    };
  };
}
