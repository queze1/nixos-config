{self, ...}: {
  flake.nixosModules.desktop = {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  flake.nixosModules.niriNoctalia = {
    imports = [
      self.nixosModules.desktop
      self.nixosModules.niri
      self.nixosModules.noctalia
    ];
  };
}
