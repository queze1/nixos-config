{
  inputs,
  self,
  ...
}: let
  hostname = "mirage-white";
in {
  # Tiny EC2 instance
  flake.nixosModules.mirageWhiteConfiguration = {config, ...}: {
    imports = [
      self.nixosModules.myOptions

      # System config
      self.nixosModules.sopsNix
      self.nixosModules.tailscale

      # Monitoring
      self.nixosModules.beszel
      self.nixosModules.beszelAgent

      # Hosted services
      self.nixosModules.cloudflared
      self.nixosModules.gatus
    ];

    # Automatically auth into Tailscale as a server
    services.tailscale = {
      authKeyFile = config.sops.secrets.tailscale-auth-key.path;
      extraUpFlags = ["--hostname=${hostname}"];
    };
    sops.secrets.tailscale-auth-key = {};

    zramSwap = {
      enable = true;
      memoryPercent = 100;
    };

    # Minimise Nix store size
    boot.loader.grub.configurationLimit = 3;
    nix.gc = {
      automatic = true;
      options = "--delete-old";
    };
    nix.settings.auto-optimise-store = true;

    # Disable documentation
    documentation.enable = false;

    nix.settings.experimental-features = ["nix-command" "flakes"];

    networking.hostName = hostname;
    system.stateVersion = "26.05";
  };

  flake.nixosConfigurations.${hostname} = inputs.nixpkgs-stable.lib.nixosSystem {
    pkgs = import inputs.nixpkgs-stable {
      system = "aarch64-linux";
      config.allowUnfree = true;
    };

    modules = [
      self.nixosModules.mirageWhiteConfiguration
      self.nixosModules.mirageWhiteHardware
    ];
  };
}
