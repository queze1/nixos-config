{ ... }:
{
  services.gnome-keyring.enable = true;
  services.syncthing = {
    enable = true;
    settings = {
      devices = {
        "poco-x3-pro" = {
          id = "CGN4GSA-JX3232W-WM5XXI6-RKU3W6F-RVAZH7N-YPOCAF3-52SRDUO-HHRFFQI";
        };
      };
      folders = {
        "SillyTavern Data" = {
          id = "nicrf-adfwa";
          path = "/mnt/utm/Apps/SillyTavern-Launcher/SillyTavern/data/default-user";
          devices = [ "poco-x3-pro" ];
        };
        "Music" = {
          id = "ft74r-2c4sc";
          path = "/mnt/utm/Music";
          devices = [ "poco-x3-pro" ];
        };
      };
    };
  };
}
