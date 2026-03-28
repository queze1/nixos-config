{ ... }:
{
  colorschemes.catppuccin.enable = true;
  plugins.lualine.enable = true;

  keymaps = [
    # Scroll down half a page and center the cursor
    {
      mode = "n";
      key = "<C-d>";
      action = "<C-d>zz";
      options.desc = "Scroll down half a page and center";
    }

    # Scroll up half a page and center the cursor
    {
      mode = "n";
      key = "<C-u>";
      action = "<C-u>zz";
      options.desc = "Scroll up half a page and center";
    }
  ];
}
