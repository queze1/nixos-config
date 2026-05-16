{ self, ... }:
{
  flake.nixosModules.niri = {
    programs.niri.enable = true;
    home-manager.sharedModules = [ self.homeModules.niri ];
  };

  flake.homeModules.niri =
    {
      pkgs,
      ...
    }:
    {
      # TODO: Convert Niri config to Nix format
      # TODO: Only enable Noctalia keybinds and autostart Noctalia if Noctalia is enabled
      # TODO: Only autostart spice-vdagentd if UTM hypervisor
      # TODO: Dynamically set browser keybind description
      xdg.configFile."niri/config.kdl".source = ./niri-config.kdl;
      home.packages = with pkgs; [
        xwayland-satellite # xwayland support
      ];
    };
}
