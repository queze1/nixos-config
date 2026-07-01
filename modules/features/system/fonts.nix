{
  flake.nixosModules.fonts = {pkgs, ...}: {
    fonts = {
      enableDefaultPackages = true;

      packages = with pkgs; [
        corefonts
        nerd-fonts.fira-code
        nerd-fonts.droid-sans-mono
      ];

      fontconfig = {
        enable = true;
        hinting = {
          enable = false;
        };
      };
    };
  };
}
