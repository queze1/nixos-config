{ pkgs, ... }:
{
  programs.fish.enable = true;
  programs.nix-ld.enable = true;

  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true;
}
