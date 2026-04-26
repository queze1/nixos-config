{ ... }:
{
  programs.fish.enable = true;
  programs.nix-ld.enable = true;

  # Add binaries to PATH
  environment.localBinInPath = true;

  services.geoclue2.enable = true;
  location.provider = "geoclue2";
}
