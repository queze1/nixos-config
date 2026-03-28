{
  description = "Home configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-index-database,
      plasma-manager,
      nvf,
      ...
    }:
    let
      lib = nixpkgs.lib;
    in
    {
      nixosModules.default =
        {
          user,
          homeProfile,
          desktop ? null,
          hypervisor ? null,
          ...
        }:
        {
          imports = [
            home-manager.nixosModules.home-manager
          ];

          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit user desktop hypervisor; # passed to all modules
          };

          home-manager.users."${user}" = {
            imports = [
              ./${homeProfile}.nix
              nix-index-database.homeModules.default
              nvf.homeManagerModules.default
            ]
            ++ lib.optional (desktop == "kde") plasma-manager.homeModules.plasma-manager;
          };
        };
    };
}
