{
  config,
  lib,
  self,
  ...
}: let
  cfg = config.my.hosts.autumn-forge;
in {
  options.my.hosts.autumn-forge.enable =
    lib.mkEnableOption "autumn-forge host configuration";

  config = lib.mkIf cfg.enable {
    environment.shellAliases = {
      nrs = "sudo darwin-rebuild switch --flake github:queze/nixos-config#";
      nrb = "sudo darwin-rebuild build --flake github:queze/nixos-config#";
      nfc = "sudo darwin-rebuild check --flake github:queze/nixos-config#";
      nrr = "sudo darwin-rebuild rollback";
    };

    # Broken, see https://github.com/nix-darwin/nix-darwin/issues/1566
    # system.keyboard = {
    #   enableKeyMapping = true;
    #   swapLeftCommandAndLeftAlt = true;
    #   swapCapsLockAndEscape = true;
    # };

    # Enable flakes
    nix.settings.experimental-features = "nix-command flakes";

    system.configurationRevision = self.rev or self.dirtyRev or null;
    system.stateVersion = 6;
    nixpkgs.hostPlatform = "aarch64-darwin";
    networking.hostName = "autumn-forge";
  };
}
