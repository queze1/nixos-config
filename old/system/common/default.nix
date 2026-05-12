{
  lib,
  hypervisor ? null,
  ...
}:
{
  imports = [
    ./desktop.nix
    ./docker.nix
    ./fonts.nix
    ./network.nix
    ./programs.nix
    ./remote-builder.nix
    ./sound.nix
  ]
  # VMs can't print
  ++ lib.optionals (builtins.isNull (hypervisor)) [ ./printing.nix ];
}
