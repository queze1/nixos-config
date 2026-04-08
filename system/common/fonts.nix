{ ... }:
{
  fonts.fontconfig = {
    enable = true;
    # For high DPI screens
    hinting = {
      enable = false;
    };
  };
}
