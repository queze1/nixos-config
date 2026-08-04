{
  description = "A basic flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs}: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    perSystem = nixpkgs.lib.genAttrs systems;
  in {
    packages = perSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.hello;
        devShells.default = pkgs.mkShell {packages = [];};
      }
    );
  };
}
