{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.able-archer = self.factory.mkNixosSystem {
    nixpkgs = inputs.nixpkgs;
    system = "aarch64-linux";
    modules = [
      {my.hosts.able-archer.enable = true;}
      (import ../../../modules/hosts/_hardware/able-archer.nix)
    ];
    extraPkgs.pkgs-stable = inputs.nixpkgs-stable;
  };
}
