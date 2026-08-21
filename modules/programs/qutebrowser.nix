{
  config,
  lib,
  ...
}: let
  cfg = config.my.programs.qutebrowser;
in {
  options.my.programs.qutebrowser.enable = lib.mkEnableOption "qutebrowser" // {default = config.my.programs.enableAll;};

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        programs.qutebrowser = {
          enable = true;
          searchEngines = {
            "DEFAULT" = "https://www.google.com/search?q={}";
            "np" = "https://search.nixos.org/packages?channel=unstable&query={}";
            "no" = "https://search.nixos.org/options?channel=unstable&query={}";
            "nho" = "https://home-manager-options.extranix.com/?query={}";
            "nw" = "https://wiki.nixos.org/w/index.php?search={}";
          };
          keyBindings = {
            normal = {
              "<Esc>" = "jseval -q document.activeElement.blur()";
            };
          };
        };
      }
    ];
  };
}
