{
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs.nixosModules = inputs.import-tree ./modules;
    } (inputs.import-tree ./outputs);

  inputs = {
    # Nix ecosystem
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets
    secrets = {
      url = "github:queze1/nixos-secrets";
      # url = "git+ssh://git@github.com/queze1/nixos-secrets.git";
      flake = false;
    };

    # Flake helpers
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    import-tree.url = "github:vic/import-tree";

    # Libraries
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation.url = "github:nix-community/preservation";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Deployment
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.stable.follows = "nixpkgs-stable";
    };
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Personal repos
    ark-rp-visualisation = {
      url = "github:queze1/ark-rp-visualisation";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Applications
    noctalia = {
      url = "github:noctalia-dev/noctalia/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      # url = "github:queze1/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Yazi plugins
    bunny-yazi = {
      url = "github:stelcodes/bunny.yazi";
      flake = false;
    };
    system-clipboard-yazi = {
      url = "github:orhnk/system-clipboard.yazi";
      flake = false;
    };
  };
}
