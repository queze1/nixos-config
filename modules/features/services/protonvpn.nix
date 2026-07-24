{
  flake.nixosModules.protonvpn = {pkgs, ...}: {
    networking.firewall.checkReversePath = false;
    environment.systemPackages = [pkgs.proton-vpn];
  };
}
