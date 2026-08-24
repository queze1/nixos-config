{
  inputs,
  self,
  ...
}: let
  hostname = "autumn-forge";
in {
  flake.darwinConfigurations.${hostname} = inputs.nix-darwin.lib.darwinSystem {
    specialArgs = {inherit self;};
    modules = [
      (import ../../modules/hosts/autumn-forge.nix)
      {my.hosts.autumn-forge.enable = true;}
    ];
  };
}
