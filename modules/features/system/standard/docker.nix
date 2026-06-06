{
  flake.nixosModules.docker = {
    virtualisation.docker = {
      enable = false;

      rootless = {
        enable = true;
        setSocketVariable = true;
        daemon.settings = {
          dns = [
            "1.1.1.1"
            "8.8.8.8"
          ];
          firewall-backend = "nftables";
          registry-mirrors = ["https://mirror.gcr.io"];
        };
      };
    };
  };
}
