{
  inputs,
  self,
  ...
}: let
  hostname = "mirage-red";
in {
  flake.nixosConfigurations.${hostname} = self.factory.mkNixosSystem {
    nixpkgs = inputs.nixpkgs-stable;
    system = "x86_64-linux";
    modules = [
      {my.hosts.mirage-red.enable = true;}
      (import ../../modules/hosts/_hardware/mirage-red.nix)
    ];
  };
}
