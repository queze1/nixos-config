{
  inputs,
  self,
  ...
}: let
  hostname = "autumn-forge";
in {
  flake.darwinModules.autumnForgeConfiguration = {pkgs, ...}: {
    imports = [
      self.darwinModules.shellAliases
    ];

    environment.systemPackages = [
      pkgs.vim
    ];

    programs.fish.enable = true;

    # Enable flakes
    nix.settings.experimental-features = "nix-command flakes";

    system.configurationRevision = self.rev or self.dirtyRev or null;
    system.stateVersion = 6;
    nixpkgs.hostPlatform = "aarch64-darwin";
  };

  flake.darwinConfigurations.${hostname} = inputs.nix-darwin.lib.darwinSystem {
    modules = [self.darwinModules.autumnForgeConfiguration];
  };
}
