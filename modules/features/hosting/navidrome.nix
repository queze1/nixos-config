{
  flake.nixosModules.navidrome = {config, ...}: {
    services.navidrome = {
      enable = true;
      settings = {
        "Scanner.Schedule" = "0 * * * *";
      };
    };

    # Preserve Navidrome data
    my.preservation.extraDirectories = [
      {
        directory = "/var/lib/navidrome";
        user = config.services.navidrome.user;
        group = config.services.navidrome.group;
        mode = "0700";
      }
    ];
  };
}
