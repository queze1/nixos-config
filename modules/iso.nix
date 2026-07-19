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

    # Helper to return
    # - isoDerivation: a Nix derivation that builds an ISO image
    # - isoPath: the path to that ISO image
    mkIso = {hostPlatform}: let
      nixos = mkIsoSystem {inherit hostPlatform;};
      isoDerivation = nixos.config.system.build.isoImage;
    in {
      inherit isoDerivation;
      isoPath = "${isoDerivation}/${nixos.config.image.filePath}";
    };

    # Wrapper around xorriso-dd-target to burn an ISO
    mkIsoBurnerScript = {
      name,
      hostPlatform,
    }:
      pkgs.writeShellScriptBin name ''
        exec ${pkgs.libisoburn}/bin/xorriso-dd-target \
          -with_sudo -plug_test -DO_WRITE \
          -image_file ${(mkIso {inherit hostPlatform;}).isoPath} \
          "$@"
      '';
  in {
    packages = {
      iso-x86 = (mkIso {hostPlatform = "x86_64-linux";}).isoDerivation;
      iso-aarch64 = (mkIso {hostPlatform = "aarch64-linux";}).isoDerivation;

      burn-iso-x86 = mkIsoBurnerScript {
        name = "burn-iso-x86";
        hostPlatform = "x86_64-linux";
      };
      burn-iso-aarch64 = mkIsoBurnerScript {
        name = "burn-iso-aarch64";
        hostPlatform = "aarch64-linux";
      };
    };
  };
}
