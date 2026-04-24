{ ... }:
{
  programs.fish.enable = true;
  programs.nix-ld.enable = true;
  services.clipboard-sync.enable = true;

  # Add binaries to PATH
  environment.localBinInPath = true;
}
