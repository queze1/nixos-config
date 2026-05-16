{ inputs, ... }:
let
  # Helper function to activate Nix-on-droid
  activateNixOnDroid =
    configuration:
    inputs.deploy-rs.lib.aarch64-linux.activate.custom configuration.activationPackage "${configuration.activationPackage}/activate";
in
{
  deploy.nodes.nix-on-droid-server = {
    hostname = "poco-x3-pro";
    profiles.system = {
      sshUser = "nix-on-droid";
      sshOpts = [
        "-p"
        "8022"
      ];
      path = activateNixOnDroid inputs.nix-on-droid-repo.nixOnDroidConfigurations.default;
      magicRollback = false;
    };
  };
}
