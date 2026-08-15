# Old implementation: https://github.com/queze1/nixos-config/blob/4401f760011a703e07107047b5a278e73df2d1d4/modules/outputs/iso.nix
# Previously allowed cross-compilation, removed as it was causing too much lag from nixd and nix flake check
{
  self,
  inputs,
  ...
}: let
  sshKeys = import "${self}/ssh-keys.nix";
in {
  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: let
    # Define an ISO as a NixOS system
    isoSystem =
      inputs.nixpkgs-stable.lib.nixosSystem
      {
        modules = [
          "${inputs.nixpkgs-stable}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          self.nixosModules.openssh
          {
            # Backdoor the ISO so I can SSH in
            users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];
            networking.networkmanager.enable = true;

            # Recommended in https://gist.github.com/baryluk/70a99b5f26df4671378dd05afef97fce
            isoImage.squashfsCompression = "zstd -Xcompression-level 6 -b 1M";
            nixpkgs.hostPlatform = system;
          }
        ];
      };

    isoImage = isoSystem.config.system.build.isoImage;
    isoPath = "${isoImage}/${isoSystem.config.image.filePath}";

    # Wrapper around xorriso-dd-target to burn an ISO
    mkIsoBurnerScript = name: let
      innerScript = pkgs.writeShellScript "burn-iso-image-internal" ''
        exec xorriso-dd-target \
          -with_sudo -plug_test -DO_WRITE \
          -image_file ${isoPath} \
          "$@"
      '';
    in
      pkgs.buildFHSEnv {
        inherit name;
        targetPkgs = pkgs:
          with pkgs; [
            libisoburn # contains xorriso-dd-target
            util-linux # contains lsblk
            coreutils # contains basic commands (cat, mkdir, etc.)
            gnugrep
            gnused
            sudo
          ];
        runScript = "${innerScript}";
      };
  in {
    packages = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      iso-system = isoSystem.config.system.build.toplevel;
      iso-image = isoImage;
      burn-iso-image = mkIsoBurnerScript "burn-iso-image";
    };
  };
}
