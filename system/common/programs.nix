{ pkgs, ... }:
{
  programs.fish.enable = true;
  programs.nix-ld.enable = true;

  # Add binaries to PATH
  environment.localBinInPath = true;
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
}
