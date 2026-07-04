{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.agenix = moduleWithSystem (
    # inputs': inputs, but with system preselected
    {inputs', ...}: {...}: {
      imports = [inputs.agenix.nixosModules.default];

      environment.systemPackages = [inputs'.agenix.packages.default];
      age.identityPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/persistent/etc/ssh/ssh_host_ed25519_key"
      ];
    }
  );

  flake.nixosModules.agenixForHM = {
    home-manager.sharedModules = [
      inputs.agenix.homeManagerModules.default
      {age.identityPaths = ["~/.ssh/id_ed25519"];}
    ];
  };
}
