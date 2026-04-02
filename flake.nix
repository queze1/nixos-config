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
      desktopDefaults = {
        plasma = false;
        niri = false;
        noctalia = false;
      };

      # Helper function to create a NixOS system
      mkSystem =
        host:
        {
          system,
          user,
          homeProfile,
          desktop ? { },
          hypervisor ? null,
        }:
        let
          # Needed so Nix doesn't complain about missing values
          desktop' = desktopDefaults // desktop;
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              self
              user
              homeProfile
              hypervisor
              ;
            desktop = desktop';
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
          hypervisor = "vmware";
          desktop = {
            plasma = true;
          };
        };
        utm-vm = {
          system = "aarch64-linux";
          user = "andrewh";
          homeProfile = "general";
          hypervisor = "utm";
          desktop = {
            niri = true;
            noctalia = true;
          };
        };
        utm-vm-2 = {
          system = "aarch64-linux";
          user = "andrewh";
          homeProfile = "general";
          hypervisor = "utm";
          desktop = {
            plasma = true;
            niri = true;
            noctalia = true;
          };
        };
      };
    in
    {
      # Use mapAttrs to create a system for each host
      nixosConfigurations = builtins.mapAttrs mkSystem hosts;
    };
}
