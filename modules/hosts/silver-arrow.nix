{
  config,
  lib,
  self,
  ...
}: let
  cfg = config.my.hosts.silver-arrow;
  hostname = config.networking.hostName;
in {
  options.my.hosts.silver-arrow.enable =
    lib.mkEnableOption "silver-arrow host configuration";

  config = lib.mkIf cfg.enable {
    environment.shellAliases = let
      darwinRebuild = "sudo darwin-rebuild --refresh --flake github:queze1/nixos-config#${hostname}";
    in {
      nrs = "${darwinRebuild} switch";
      nrb = "${darwinRebuild} boot";
      nfc = "${darwinRebuild} check";
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
    networking.hostName = "silver-arrow";
  };
}
