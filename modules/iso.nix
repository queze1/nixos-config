{
  self,
  inputs,
  ...
}: let
  sshKeys = import "${self}/ssh-keys.nix";

  # Helper to make an ISO image
  mkIso = {
    hostPlatform,
    buildPlatform,
  }:
    (inputs.nixpkgs-stable.lib.nixosSystem
      {
        modules = [
          "${inputs.nixpkgs-stable}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          self.nixosModules.openssh
          {
            # Backdoor the ISO so I can SSH in
            users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];
            networking.networkmanager.enable = true;
            nixpkgs.hostPlatform = hostPlatform;
            nixpkgs.buildPlatform = buildPlatform;
          }
        ];
      }).config.system.build.isoImage;
in {
  perSystem = {system, ...}: let
  in {
    packages = {
      iso-x86 = mkIso {
        hostPlatform = "x86_64-linux";
        buildPlatform = system;
      };
      iso-aarch64 = mkIso {
        hostPlatform = "aarch64-linux";
        buildPlatform = system;
      };
    };
  };
}
