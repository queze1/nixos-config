{
  self,
  inputs,
  ...
}: let
  sshKeys = import "${self}/ssh-keys.nix";

  mkIso = {
    hostPlatform,
    buildPlatform ? "aarch64-linux",
  }:
    inputs.nixpkgs-stable.lib.nixosSystem {
      modules = [
        "${inputs.nixpkgs-stable}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
        self.nixosModules.openssh
        {
          # Backdoor the ISO so I can SSH in
          users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];
          nixpkgs.hostPlatform = hostPlatform;
          nixpkgs.buildPlatform = buildPlatform;
        }
      ];
    };
in {
  flake.nixosConfigurations = {
    iso-x86 = mkIso {
      hostPlatform = "x86_64-linux";
      buildPlatform = "aarch64-darwin";
    };

    iso-aarch64 = mkIso {
      hostPlatform = "aarch64-linux";
      buildPlatform = "aarch64-darwin";
    };
  };
}
