{
  flake-parts.url = "github:hercules-ci/flake-parts";
  import-tree.url = "github:vic/import-tree";

  wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

  agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  preservation.url = "github:nix-community/preservation";

  deploy-rs.url = "github:serokell/deploy-rs";
}
