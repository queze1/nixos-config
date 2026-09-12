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
      (import ../../modules/hosts/silver-arrow.nix)
      {my.hosts.silver-arrow.enable = true;}
    ];
  };
}
