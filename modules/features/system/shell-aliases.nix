{self, ...}: {
  flake.nixosModules.shellAliases = {pkgs, ...}: let
  in {
    environment.shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/etc/nixos#";
      nrb = "sudo nixos-rebuild boot --flake ~/etc/nixos#";
      nix-direnv-init = "nix flake new -t github:nix-community/nix-direnv .";
      g = "git";
    };

    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.flake-update
    ];
  };
}
