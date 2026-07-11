{inputs, ...}: {
  flake.nixosModules.arkRpVisualisation = {config, ...}: {
    # Create a system user and group
    users.users.ark-rp-viz = {
      isSystemUser = true;
      group = "ark-rp-viz";
      linger = true;
    };
    users.groups.ark-rp-viz = {};

    age.secrets.ark-rp-visualisation-env = {
      file = "${inputs.secrets}/ark-rp-visualisation-env.age";
      user = "ark-rp-viz";
      group = "ark-rp-viz";
    };

    virtualisation.oci-containers = {
      containers.ark-rp-viz = {
        # TODO: Pull in the repo as an input and build the Docker image
        image = "ark-rp-visualisation:latest";
        ports = ["127.0.0.1:8050:8050"];
        autoStart = true;
        podman.user = "ark-rp-viz";

        environmentFiles = [config.age.secrets.ark-rp-visualisation-env.path];
      };
    };
  };
}
