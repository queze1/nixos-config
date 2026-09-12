{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.programs.protonvpn;
in {
  options.my.programs.protonvpn.enable = lib.mkEnableOption "Proton VPN" // {default = config.my.programs.enableAll;};

  config = lib.mkIf cfg.enable {
    networking.firewall.checkReversePath = lib.mkForce false;
    environment.systemPackages = [pkgs.proton-vpn];
  };
}
