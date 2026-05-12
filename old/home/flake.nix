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

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
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

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      home-manager,
      ...
    }:
    {
      nixosModules.default =
        nixosArgs@{
          homeProfile,
          user,
          desktop ? { },
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
              inputs
              user
              desktop
              hypervisor
              ;
            pkgs-stable = nixosArgs.pkgs-stable;
          };

          # Backup with an incrementing number
          home-manager.backupCommand = ''
            filename="$1"
            extension="backup"
            if [ -e "$filename.$extension" ]; then
                count=1
                while [ -e "$filename.$extension.$count" ]; do
                    count=$((count + 1))
                done
                mv "$filename" "$filename.$extension.$count"
            else
                mv "$filename" "$filename.$extension"
            fi
          '';

          home-manager.users."${user}" = {
            imports = [
              ./${homeProfile}.nix
              inputs.nix-index-database.homeModules.default
              inputs.agenix.homeManagerModules.default
            ];
          };
        };
    };
}
