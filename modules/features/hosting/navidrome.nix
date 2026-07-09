{
  flake.nixosModules.navidrome = {
    services.navidrome = {
      enable = true;
      settings = {
        "Scanner.Schedule" = "0 * * * *";
      };
    };
  };
}
