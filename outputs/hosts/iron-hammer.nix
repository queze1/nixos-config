{
  inputs,
  self,
  ...
}: let
  hostname = "iron-hamer";
in {
  flake.nixosConfigurations.${hostname} = self.factory.mkNixosSystem {
    nixpkgs = inputs.nixpkgs;
    system = "aarch64-linux";
    modules = [{my.hosts.${hostname}.enable = true;}];
    extraPkgs.pkgs-stable = inputs.nixpkgs-stable;
  };
}
