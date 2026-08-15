{inputs, ...}: {
  flake.nixosModules.comin = {
    imports = [inputs.comin.nixosModules.comin];

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

    my.preservation.extraDirectories = ["/var/lib/comin"];
  };
}
