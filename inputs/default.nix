{
  imports = [
    ./libraries.nix
    ./programs.nix
  ];

  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

  home-manager.url = "github:nix-community/home-manager";

  nix-on-droid-repo = {
    url = "github:queze1/nix-on-droid-config";
    inputs.nixpkgs.follows = "nixpkgs-stable";
    inputs.nixpkgs-unstable.follows = "nixpkgs";
  };
}
