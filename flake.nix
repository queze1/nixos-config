{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-config = {
      url = "path:./home";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "";

    # For build-time secrets
    my-secrets.url = "git+ssh://git@github.com/queze1/nixos-secrets.git";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:

    let
      # Helper function to create a NixOS system
      mkSystem =
        host:
        {
          system,
          user,
          homeProfile,
          desktop ? null,
          hypervisor ? null,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              self
              user
              desktop
              homeProfile
              hypervisor
              ;
          };

          modules = [
            # Per-host system settings (e.g. kernel, hardware config)
            ./hosts/${host}
            # Per-user system settings (e.g. user creation)
            ./users/${user}.nix
            # Home profile
            inputs.home-config.nixosModules.default

            # My real name
            {
              users.users.andrewh.description = inputs.my-secrets.realName;
            }
            inputs.disko.nixosModules.disko
            inputs.agenix.nixosModules.default
          ];
        };

      hosts = {
        vmware-vm = {
          system = "aarch64-linux";
          user = "andrewh";
          homeProfile = "general";
          desktop = "kde";
          hypervisor = "vmware";
        };
        utm-vm = {
          system = "aarch64-linux";
          user = "andrewh";
          homeProfile = "general";
          desktop = "kde";
          hypervisor = "utm";
        };
        utm-vm-2 = {
          system = "aarch64-linux";
          user = "andrewh";
          homeProfile = "general";
          desktop = "kde";
          hypervisor = "utm";
        };
      };
    in
    {
      # Use mapAttrs to create a system for each host
      nixosConfigurations = builtins.mapAttrs mkSystem hosts;
    };
}
