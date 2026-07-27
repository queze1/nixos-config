{
  flake.nixosModules.comin = {
    services.comin = {
      enable = true;
      remotes = [
        {
          name = "origin";
          url = "https://github.com/queze1/nixos-config.git";
          branches.main.name = "deployed";
        }
      ];
    };
  };
}
