{ inputs, moduleWithSystem, ... }:
{
  flake.nixosModules.agenix = moduleWithSystem (
    # inputs': inputs, but with system preselected
    { inputs', ... }:
    { ... }:
    {
      imports = [ inputs.agenix.nixosModules.default ];

      environment.systemPackages = [ inputs'.agenix.packages.default ];

      virtualisation.sharedDirectories = {
        ssh-keys = {
          source = "/etc/ssh";
          target = "/etc/ssh";
        };
      };

      age = {
        identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    }
  );
}
