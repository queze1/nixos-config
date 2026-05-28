{ self, ... }:
{
  flake.nixosModules.desktop = {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = false;
    };

    services.xserver.enable = true;

    # For testing only
    programs.niri.enable = true;
  };

  flake.nixosModules.niriNoctalia = {
    imports = [
      self.nixosModules.desktop
      self.nixosModules.niri
    ];

    home-manager.sharedModules = [
      self.homeModules.noctalia
    ];
  };
}
