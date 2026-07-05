{
  self,
  inputs,
  ...
}: let
  hostname = "steadfast-defender";
in {
  # ThinkPad home server
  flake.nixosModules.steadfastDefenderConfiguration = {
    imports = [self.nixosModules.steadfastBase];

    # Services
    services.caddy = {
      enable = true;
    };
    services.navidrome = {
      enable = true;
      settings = {
        "Scanner.Schedule" = "0 * * * *";
      };
    };

    hardware.facter.reportPath = ./facter.json;
    networking.hostName = "${hostname}";
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    modules = [self.nixosModules.steadfastDefenderConfiguration];
  };
}
