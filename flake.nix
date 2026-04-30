{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    home-config = {
      url = "path:./home";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "";

    deploy-rs.url = "github:serokell/deploy-rs";

    nix-on-droid-repo = {
      url = "github:queze1/nix-on-droid-config";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.nixpkgs-unstable.follows = "nixpkgs";
    };

    # For build-time secrets
    # my-secrets.url = "git+ssh://git@github.com/queze1/nixos-secrets.git";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      deploy-rs,
      ...
    }:
    let
      # Helper function to activate Nix-on-droid
      activateNixOnDroid =
        configuration:
        deploy-rs.lib.aarch64-linux.activate.custom configuration.activationPackage "${configuration.activationPackage}/activate";

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
          pkgs-stable = nixpkgs-stable.legacyPackages.${system};

          # Needed so Nix doesn't complain about missing values
          desktop' = {
            plasma = false;
            niri = false;
            noctalia = false;
          }
          // desktop;
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              self
              pkgs-stable
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

            {
              environment.systemPackages = [ inputs.agenix.packages.${system}.default ];
            }
            inputs.disko.nixosModules.disko
            inputs.agenix.nixosModules.default
          ];
        };

      hosts = {
        vmware-vm = {
          system = "aarch64-linux";
          user = "queze";
          homeProfile = "general";
          hypervisor = "vmware";
          desktop = {
            plasma = true;
          };
        };
        utm-vm = {
          system = "aarch64-linux";
          user = "queze";
          homeProfile = "general";
          hypervisor = "utm";
          desktop = {
            niri = true;
            noctalia = true;
          };
        };
      };
    in
    {
      # Use mapAttrs to create a system for each host
      nixosConfigurations = builtins.mapAttrs mkSystem hosts;

      deploy.nodes.nix-on-droid-server = {
        hostname = "poco-x3-pro";
        profiles.system = {
          sshUser = "nix-on-droid";
          sshOpts = [
            "-p"
            "8022"
          ];
          path = activateNixOnDroid inputs.nix-on-droid-repo.nixOnDroidConfigurations.default;
          magicRollback = false;
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
