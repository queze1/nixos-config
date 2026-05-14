{
  flake.nixosModules.standardSystem = {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    # GNOME Keyring
    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;
  };
}
