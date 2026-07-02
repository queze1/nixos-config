{self, ...}: {
  flake.nixosModules.shellAliases = {pkgs, ...}: let
  in {
    environment.shellAliases = {
      nrs = "sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild switch --flake ~/etc/nixos#";
      nrb = "sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild boot --flake ~/etc/nixos#";
      nix-direnv-init = "nix flake new -t github:nix-community/nix-direnv .";
      g = "git";
    };

    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.flake-update
    ];
  };
}
