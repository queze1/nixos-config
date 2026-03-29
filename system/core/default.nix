{
  ...
}:
{
  imports = [
    ./boot.nix
    ./localisation.nix
    ./networking.nix
    ./nix.nix
    ./printing.nix
    ./sound.nix
  ];

  # Enable zRAM
  zramSwap.enable = true;

  # Configure SSH
  programs.ssh.startAgent = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
