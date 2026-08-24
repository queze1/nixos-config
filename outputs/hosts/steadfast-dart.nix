{
  inputs,
  self,
  ...
}: let
  hostname = "steadfast-dart";
in {
  flake.nixosConfigurations.${hostname} = self.factory.mkNixosSystem {
    nixpkgs = inputs.nixpkgs-stable;
    system = "x86_64-linux";
    modules = [{my.hosts.steadfast-dart.enable = true;}];
  };
}
