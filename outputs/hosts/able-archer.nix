{
  inputs,
  self,
  ...
}: let
  hostname = "able-archer";
in {
  flake.nixosConfigurations.${hostname} = self.factory.mkNixosSystem {
    nixpkgs = inputs.nixpkgs;
    system = "aarch64-linux";
    modules = [
      {my.hosts.${hostname}.enable = true;}
      (import ../../modules/hosts/_hardware/${hostname}.nix)
    ];
    extraPkgs.pkgs-stable = inputs.nixpkgs-stable;
  };
}
