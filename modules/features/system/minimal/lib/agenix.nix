{
  inputs,
  moduleWithSystem,
  self,
  ...
}:
{
  flake.nixosModules.agenix = moduleWithSystem (
    # inputs': inputs, but with system preselected
    { inputs', ... }:
    { ... }:
    {
      imports = [ inputs.agenix.nixosModules.default ];

      environment.systemPackages = [ inputs'.agenix.packages.default ];
      age.identityPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/persistent/etc/ssh/ssh_host_ed25519_key"
      ];

      home-manager.sharedModules = [ self.homeModules.agenix ];
    }
  );

  flake.homeModules.agenix =
    { config, ... }:
    {
      imports = [
        inputs.agenix.homeManagerModules.default
      ];

      age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    };
}
