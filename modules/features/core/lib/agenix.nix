{
  inputs,
  moduleWithSystem,
  self,
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

      # Set where secrets will be decrypted
      age.secrets = {
        queze-password.file = "${self}/secrets/queze-password.age";
        queze-ssh-config = {
          file = "${self}/secrets/queze-ssh-config.age";
          path = "/home/queze/.ssh/config";
          owner = "queze";
          mode = "600";
        };
        tavily-api-key.file = "${self}/secrets/tavily-api-key.age";
        commander-password.file = "${self}/secrets/commander-password.age";
      };
    }
  );
}
