{
  lib,
  hypervisor ? null,
  ...
}:
{
  imports = [
    ./desktop.nix
    ./docker.nix
    ./p2p-vpn.nix
    ./remote-builder.nix
    ./sound.nix
  ]
  # VMs can't print
  ++ lib.optionals (builtins.isNull (hypervisor)) [ ./printing.nix ];

  # Enable Fish
  programs.fish.enable = true;

  programs.nix-ld.enable = true;
}
