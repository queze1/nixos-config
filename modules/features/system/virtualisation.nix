{
  flake.nixosModules.virtualisation =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/virtualisation/qemu-vm.nix")
      ];

      virtualisation.vmVariant = {
        users.mutableUsers = false;
        users.users.root.password = "root";

        # Share host keys with VM
        virtualisation.sharedDirectories = {
          ssh-keys = {
            source = "/etc/ssh";
            target = "/etc/ssh";
          };
        };
      };
    };
}
