{
  self,
  inputs,
  ...
}: let
  hostname = "steadfast-defender";
in {
  flake.nixosConfigurations.${hostname} = self.factory.mkNixosSystem {
    nixpkgs = inputs.nixpkgs-stable;
    system = "x86_64-linux";
    modules = [{my.hosts.steadfast-defender.enable = true;}];
  };
}
