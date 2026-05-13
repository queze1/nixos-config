{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "able-archer";
  system.stateVersion = "25.11";
}
