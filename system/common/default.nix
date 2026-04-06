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
    ./programs.nix
  ]
  # VMs can't print
  ++ lib.optionals (builtins.isNull (hypervisor)) [ ./printing.nix ];
}
