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

      # Specify where secrets are
      age.secrets = {
        queze-ssh-config = {
          file = "${inputs.secrets}/secrets/queze-ssh-config.age";
          path = "/home/queze/.ssh/config";
          owner = "queze";
          mode = "600";
        };
        tavily-api-key.file = "${inputs.secrets}/secrets/tavily-api-key.age";
        tailscale-auth-key.file = "${inputs.secrets}/secrets/tailscale-auth-key.age";
      };
    }
  );
}
