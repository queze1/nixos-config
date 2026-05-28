{ self, ... }:
{
  flake.nixosModules.desktop = {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    programs.niri.enable = true;

    # Keyring support
    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;
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
