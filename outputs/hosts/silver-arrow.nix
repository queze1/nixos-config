{
  inputs,
  self,
  ...
}: let
  hostname = "silver-arrow";
in {
  flake.darwinConfigurations.${hostname} = inputs.nix-darwin.lib.darwinSystem {
    specialArgs = {inherit self;};
    modules = [
      (import ../../modules/hosts/${hostname}.nix)
      {my.hosts.${hostname}.enable = true;}
    ];
  };
}
