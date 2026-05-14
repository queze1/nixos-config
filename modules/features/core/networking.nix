{
  flake.nixosModules.networking =
    { ... }:
    {
      # TODO: Handle firewall, Tailscale SSH, depending on profile
      networking.networkmanager.enable = true;

      # Disable on personal machines, insecure
      # services.openssh = {
      #   enable = true;
      #   settings = {
      #     PasswordAuthentication = false;
      #     KbdInteractiveAuthentication = false;
      #     PermitRootLogin = "no";
      #   };
      #   hostKeys = [
      #     {
      #       path = "/etc/ssh/ssh_host_ed25519_key";
      #       type = "ed25519";
      #     }
      #   ];
      # };
    };
}
