{
  flake.nixosModules.preservation =
    { config, inputs, ... }:
    {
      imports = [ inputs.preservation.nixosModules.defaul ];

      # TODO: Check if a persistence disko config is on
      boot.tmp.cleanOnBoot = true;

      preservation = {
        enable = true;

        preserveAt."/persistent" = {
          directories = [
            "/etc/NetworkManager/system-connections"
            "/tmp" # prevent running out of memory from temp files
            "/var/lib/fwupd"
            "/var/lib/libvirt"
            "/var/lib/systemd/coredump"
            "/var/lib/systemd/rfkill"
            "/var/lib/systemd/timers"
            "/var/log"
            {
              directory = "/var/lib/nixos";
              inInitrd = true;
            }
          ];

          files = [
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
            {
              file = "/etc/ssh/ssh_host_rsa_key";
              how = "symlink";
              configureParent = true;
            }
            {
              file = "/etc/ssh/ssh_host_ed25519_key";
              how = "symlink";
              configureParent = true;
            }
            {
              file = "/var/lib/systemd/random-seed";
              how = "symlink";
              inInitrd = true;
              configureParent = true;
            }
          ];
        };
      };
    };
}
