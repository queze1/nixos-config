{ ... }:
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
    settings = {
      "content.headers.user_agent" = "Mozilla/5.0 ({os_info}; rv:150.0) Gecko/20100101 Firefox/150.0";
    };
  };
}
