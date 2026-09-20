{
  inputs,
  self,
  ...
}: let
  hostname = "iron-hammer";
in {
  flake.nixosConfigurations.${hostname} = self.factory.mkNixosSystem {
    nixpkgs = inputs.nixpkgs;
    system = "x86_64-linux";
    modules = [{my.hosts.${hostname}.enable = true;}];
    extraPkgs.pkgs-stable = inputs.nixpkgs-stable;
  };
}
