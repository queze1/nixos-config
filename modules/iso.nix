{
  self,
  inputs,
  ...
}: let
  sshKeys = import "${self}/ssh-keys.nix";
in {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    # Helper to generate a NixOS system to build an ISO image of
    mkIsoSystem = {hostPlatform}:
      inputs.nixpkgs-stable.lib.nixosSystem
      {
        modules = [
          "${inputs.nixpkgs-stable}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          self.nixosModules.openssh
          {
            # Backdoor the ISO so I can SSH in
            users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];
            networking.networkmanager.enable = true;
            nixpkgs.hostPlatform = hostPlatform;
            nixpkgs.buildPlatform = system;
          }
        ];
      };

    # Helper to generate an ISO
    mkIso = {hostPlatform}: let
      nixos = mkIsoSystem {inherit hostPlatform;};
      isoDerivation = nixos.config.system.build.isoImage;
    in {
      inherit isoDerivation;
      isoPath = "${isoDerivation}/${nixos.config.image.filePath}";
    };
  in {
    packages = {
      iso-x86 = (mkIso {hostPlatform = "x86_64-linux";}).isoDerivation;
      iso-aarch64 = (mkIso {hostPlatform = "aarch64-linux";}).isoDerivation;

      burn-iso = pkgs.writeShellScriptBin "burn-iso" ''
        set -e
        echo ${(mkIso {hostPlatform = "x86_64-linux";}).isoPath}
      '';
    };
  };
}
