{
  lib,
  hypervisor ? null,
  ...
}:

let
  hasVmProfile = builtins.elem hypervisor [
    "utm"
    "vmware"
  ];
in
{
  config = lib.mkMerge [
    {
      networking.networkmanager.enable = true;
    }

    # Allow toggling metered on VMs
    (lib.mkIf hasVmProfile {
      networking.networkmanager.ensureProfiles = {
        profiles = {
          "internet" = {
            connection = {
              id = "Internet";
              type = "ethernet";
              interface-name = "enp2s0";
            };
            connection.metered = "no";
          };

          "internet-metered" = {
            connection = {
              id = "Internet (metered)";
              type = "ethernet";
              interface-name = "enp2s0";
            };
            connection.metered = "yes";
          };
        };
      };
    })
  ];
}
