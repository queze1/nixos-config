{
  # TODO: Import inputs from a /inputs folder
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager.url = "github:nix-community/home-manager";

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

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Yazi plugins
    bunny-yazi = {
      url = "github:stelcodes/bunny.yazi";
      flake = false;
    };
    system-clipboard-yazi = {
      url = "github:orhnk/system-clipboard.yazi";
      flake = false;
    };

    deploy-rs.url = "github:serokell/deploy-rs";

    nix-on-droid-repo = {
      url = "github:queze1/nix-on-droid-config";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.nixpkgs-unstable.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
