{ ... }:
{
  imports = [
    ./desktop.nix
    ./printing.nix
    ./remote-builder.nix
    ./sound.nix
  ];

  # Enable Fish
  programs.fish.enable = true;
}
