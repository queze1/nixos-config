{
  self,
  inputs,
  ...
}: let
  sshKeys = import "${self}/ssh-keys.nix";

  # Helper to create a NixOS system which can generate an ISO for a given platform
  mkIso = {hostPlatform}:
    inputs.nixpkgs-stable.lib.nixosSystem {
      modules = [
        "${inputs.nixpkgs-stable}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        self.nixosModules.openssh
        {
          # Backdoor the ISO so I can SSH in
          users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];
          networking.networkmanager.enable = true;
          nixpkgs.hostPlatform = hostPlatform;
        }
      ];
    };
in {
  flake.nixosConfigurations = {
    iso-x86 = mkIso {hostPlatform = "x86_64-linux";};
    iso-aarch64 = mkIso {hostPlatform = "aarch64-linux";};
  };

  perSystem = {system, ...}: let
    # Helper which injects the current system as the buildPlatform, then extracts the ISO derivation
    buildIsoForSystem = nixosConfig:
      (nixosConfig.extendModules {
        modules = [{nixpkgs.buildPlatform = system;}];
      }).config.system.build.isoImage;
  in {
    packages = {
      # E.g. When you run `nix build .#iso-x86` on an aarch64-linux host,
      # it evaluates this package under packages.aarch64-linux.iso-x86
      # and sets buildPlatform = "aarch64-linux"
      iso-x86 = buildIsoForSystem self.nixosConfigurations.iso-x86;
      iso-aarch64 = buildIsoForSystem self.nixosConfigurations.iso-aarch64;
    };
  };
}
