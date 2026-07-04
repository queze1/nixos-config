{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.agenix = {
    imports = [inputs.agenix.nixosModules.default];

    age.identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/persistent/etc/ssh/ssh_host_ed25519_key"
    ];
  };

  flake.nixosModules.agenixWithHM = {
    home-manager.sharedModules = [
      self.homeModules.agenix
    ];
  };

  flake.homeModules.agenix = {config, ...}: {
    imports = [
      inputs.agenix.homeManagerModules.default
    ];

    age.identityPaths = [
      "${config.home.homeDirectory}/.ssh/id_ed25519"
    ];
  };
}
