{ inputs, moduleWithSystem, ... }:
{
  flake.nixosModules.agenix = moduleWithSystem (
    # inputs': inputs, but with system preselected
    { inputs', ... }:
    { ... }:
    {
      imports = [ inputs.agenix.nixosModules.default ];

      environment.systemPackages = [ inputs'.agenix.packages.default ];

      age = {
        identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    }
  );

  # TODO: Inject keys for rebuild-vm
}
