{ self, ... }:
{
  flake.nixosModules.ableArcherConfiguration = {
    imports = [
      self.nixosModules.allPrograms
      self.nixosModules.queze
      self.nixosModules.standardSystem
      self.nixosModules.niriNoctalia
    ];

    host = {
      hypervisor.type = "utm";
      disko.profile = "hybrid-tmpfs-on-root";
      preservation.enable = true;
    };

    networking.hostName = "able-archer";
    system.stateVersion = "25.11";

    # Sync with phone home server
    services.syncthing = {
      enable = true;
      user = "queze";
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
  };
}
