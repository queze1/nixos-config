{ ... }:
{
  programs.fish.enable = true;
  programs.nix-ld.enable = true;

  # Add binaries to PATH
  environment.localBinInPath = true;

  services.redshift = {
    enable = true;
    temperature = {
      day = 5500;
      night = 3700;
    };
  };

  services.geoclue2.enable = true;
  location.provider = "geoclue2";
}
