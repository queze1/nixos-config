{ pkgs, ... }:
{
  fonts.fontconfig = {
    enable = true;
    # For high DPI screens
    hinting = {
      enable = false;
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];
}
