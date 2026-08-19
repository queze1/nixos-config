{
  inputs,
  self,
  ...
}: let
  hostname = "autumn-forge";
in {
  flake.darwinModules.autumnForgeConfiguration = {
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
    networking.hostName = hostname;
  };

  flake.darwinConfigurations.${hostname} = inputs.nix-darwin.lib.darwinSystem {
    modules = [self.darwinModules.autumnForgeConfiguration];
  };
}
