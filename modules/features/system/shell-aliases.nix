{self, ...}: {
  flake.nixosModules.shellAliases = {pkgs, ...}: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.flake-update
      self.packages.${pkgs.stdenv.hostPlatform.system}.nrs
      self.packages.${pkgs.stdenv.hostPlatform.system}.nrb

      pkgs.nix-output-monitor # prettier nix builds
    ];

    environment.shellAliases = {
      nfc = "nix flake check";
      nix-flake-init = "nix flake new -t github:queze1/nixos-config .#flake";
    };
  };

  flake.darwinModules.shellAliases = {
    environment.shellAliases = {
      nrs = "sudo darwin-rebuild switch --flake github:queze/nixos-config#";
      nrb = "sudo darwin-rebuild build --flake github:queze/nixos-config#";
      nfc = "sudo darwin-rebuild check --flake github:queze/nixos-config#";
      nrr = "sudo darwin-rebuild rollback";
    };
  };
}
