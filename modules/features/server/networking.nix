{
  flake.nixosModules.serverNetworking = {config, ...}: {
    networking.wireless.iwd.enable = true;

    services.tailscale = {
      enable = true;
      openFirewall = true;
      authKeyFile = config.age.secrets.tailscale-auth-key.path;
    };

    services.openssh = {
      enable = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        UsePAM = false;
      };
    };
  };
}
