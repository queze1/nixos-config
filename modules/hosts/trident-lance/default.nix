{
  inputs,
  self,
  ...
}: let
  hostname = "trident-lance";
  sshKeys = import "${self}/ssh-keys.nix";
in {
  # Configuration for testing on cloud (CURRENTLY BROKEN)
  flake.nixosModules.tridentLanceConfiguration = {
    imports = [
      self.nixModules.myOptions
      self.nixosModules.sharedModules

      # Basic libraries
      (self.factory.diskoSimpleEfi
        {device = "/dev/vda";})
      self.nixosModules.sopsNix

      # Nix-related
      self.nixosModules.setupAccessTokens

      # Services
      self.nixosModules.comin
      self.nixosModules.openssh
    ];

    # Allow SSH into root
    users.users.root.openssh.authorizedKeys.keys = [sshKeys.ableArcherKey];

    networking.hostName = hostname;
    system.stateVersion = "25.11";
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [self.nixosModules.tridentLanceConfiguration];
  };
}
