{ inputs, ... }:
{
  flake.nixosModules.preservation =
    { config, lib, ... }:
    let
      cfg = config.host.preservation;
    in
    {
      imports = [ inputs.preservation.nixosModules.default ];

      options.host.preservation = {
        enable = lib.mkEnableOption "impermanence with preservation";
      };

      config = {
        preservation = {
          enable = cfg.enable;

          preserveAt."/persistent" = {
            directories = [
              "/etc/NetworkManager/system-connections"
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

        # Prevent conflict with preservation
        systemd.services.systemd-machine-id-commit.enable = false;
      };
    };
}
