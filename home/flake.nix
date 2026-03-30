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

    dc-tec-nixvim.url = "github:dc-tec/nixvim";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-index-database,
      plasma-manager,
      dc-tec-nixvim,
      ...
    }:
    {
      nixosModules.default =
        {
          user,
          homeProfile,
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
            inherit
              user
              hypervisor
              dc-tec-nixvim
              ;
          };

          home-manager.users."${user}" = {
            imports = [
              ./${homeProfile}.nix
              nix-index-database.homeModules.default
              plasma-manager.homeModules.plasma-manager
            ];
          };
        };
    };
}
