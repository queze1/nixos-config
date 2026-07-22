{
  inputs,
  self,
  ...
}: let
  hostname = "autumn-forge";
in {
  flake.darwinModules.autumnForgeConfiguration = {
    imports = [
      self.darwinModules.shellAliases
      self.darwinModules.homeManager
    ];

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
