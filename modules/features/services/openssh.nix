{
  flake.nixosModules.openssh = {
    services.openssh = {
      enable = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
        UsePAM = true;
      };
    };
  };
}
