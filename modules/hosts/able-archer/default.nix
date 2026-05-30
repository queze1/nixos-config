{
  self,
  inputs,
  withSystem,
  ...
}:
{
  flake.nixosConfigurations.able-archer = withSystem "aarch64-linux" (
    { self', ... }:
    inputs.nixpkgs.lib.nixosSystem {
      # Allow NixOS modules to access pkgs-stable
      specialArgs = {
        pkgs-stable = self'.legacyPackages.pkgs-stable;
      };

      modules = [
        self.nixosModules.ableArcherConfiguration
        self.nixosModules.ableArcherHardware
      ];
    }
  );
}
