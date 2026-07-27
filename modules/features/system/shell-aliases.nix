{self, ...}: {
  flake.nixosModules.shellAliases = {pkgs, ...}: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.flake-update
      pkgs.nix-output-monitor # prettier nix builds
    ];

    environment.shellAliases = let
      mkPrettyRebuild = name: "sudo -v && sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild ${name} --flake ~/etc/nixos# 2>&1 | nom";
    in {
      nrs = mkPrettyRebuild "switch";
      nrb = mkPrettyRebuild "boot";
      nfc = "nix flake check";
      nix-direnv-init = "nix flake new -t github:nix-community/nix-direnv .";
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
