{ ... }:
{
  imports = [
    ./desktop.nix
    ./p2p-vpn.nix
    ./printing.nix
    ./remote-builder.nix
    ./sound.nix
  ];

  # Enable Fish
  programs.fish.enable = true;
}
