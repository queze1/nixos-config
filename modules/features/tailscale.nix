{
  flake.nixosModules.tailscale = {
    services.tailscale = {
      # Could use the "Modern Setup" in the wiki
      # But would rather not do things I don't understand
      enable = true;
    };

    my.preservation.extraDirectories = [
      {
        directory = "/var/lib/tailscale";
        mode = "0700";
      }
    ];
  };

  flake.nixosModules.preservation = {
    # Ensure Tailscale waits for preservation
    systemd.services.tailscaled.after = ["preservation.target"];
    systemd.services.tailscaled.wants = ["preservation.target"];
  };
}
