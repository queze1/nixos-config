{self, ...}: {
  flake.nixosModules.shellAliases = {pkgs, ...}: let
  in {
    environment.shellAliases = {
      nrs = "sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild switch --flake ~/etc/nixos#";
      nrb = "sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild boot --flake ~/etc/nixos#";
      nfc = "nix flake check";
      nix-direnv-init = "nix flake new -t github:nix-community/nix-direnv .";
    };

    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.flake-update
    ];
  };

  flake.darwinModules.shellAliases = {
    environment.shellAliases = {
      nrs = "sudo darwin-rebuild switch --flake ~/.config/nixos#";
      nrb = "sudo darwin-rebuild build --flake ~/.config/nixos#";
      nfc = "sudo darwin-rebuild check --flake ~/.config/nixos#";
      nrr = "sudo darwin-rebuild rollback";
    };
  };
}
