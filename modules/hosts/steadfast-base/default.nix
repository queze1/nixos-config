{
  self,
  inputs,
  ...
}: {
  # Base configuration for home servers
  flake.nixosModules.steadfastBase = {pkgs, ...}: {
    imports = [
      self.nixosModules.coreFeatures
      self.nixosModules.minimalPrograms
      self.nixosModules.commander
    ];

    host = {
      profiles.server.enable = true;
      disko.profile = "hybrid-tmpfs-on-root";
      preservation.enable = true;
    };

    _module.args.pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${pkgs.system};

    system.stateVersion = "25.11";
  };
}
