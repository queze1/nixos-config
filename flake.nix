{
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./outputs);

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "nixpkgs-unstable"; # alias to nixpkgs-unstable
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-actions-languageserver.url = "github:keirlawson/nixpkgs/init-actions-languageserver";
    home-manager.url = "github:nix-community/home-manager";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Secrets
    secrets = {
      url = "github:queze1/nixos-secrets";
      # url = "git+ssh://git@github.com/queze1/nixos-secrets.git";
      flake = false;
    };

    # Nix utilities
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    preservation.url = "github:nix-community/preservation";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Deployment
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.stable.follows = "nixpkgs-stable";
    };
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Applications
    noctalia = {
      url = "github:noctalia-dev/noctalia/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Packaging
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Personal applications
    ark-rp-visualisation = {
      url = "github:queze1/ark-rp-visualisation";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.pyproject-build-systems.follows = "pyproject-build-systems";
    };

    # Non-flake applications
    creamlinux-installer = {
      url = "github:Novattz/creamlinux-installer";
      flake = false;
    };
    filebrowser-quantum = {
      url = "github:gtsteffaniak/filebrowser";
      flake = false;
    };
    tumblr-backup = {
      url = "github:cebtenzzre/tumblr-utils";
      flake = false;
    };
    github2forgejo = {
      url = "github:PatNei/GITHUB2FORGEJO";
      flake = false;
    };

    # Neovim plugins
    github-actions-nvim = {
      url = "github:skanehira/github-actions.nvim";
      flake = false;
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
