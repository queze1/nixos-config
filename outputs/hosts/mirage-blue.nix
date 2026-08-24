{
  inputs,
  self,
  ...
}: let
  hostname = "mirage-blue";
in {
  flake.nixosConfigurations.${hostname} = self.factory.mkNixosSystem {
    nixpkgs = inputs.nixpkgs-stable;
    system = "x86_64-linux";
    modules = [
      {my.hosts.mirage-blue.enable = true;}
      (import ../../modules/hosts/_hardware/mirage-blue.nix)
    ];
  };
}
