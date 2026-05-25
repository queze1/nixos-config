{
  nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  noctalia = {
    url = "github:noctalia-dev/noctalia-shell";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  nvf = {
    url = "github:notashelf/nvf";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # --- Yazi plugins ---
  bunny-yazi = {
    url = "github:stelcodes/bunny.yazi";
    flake = false;
  };

  system-clipboard-yazi = {
    url = "github:orhnk/system-clipboard.yazi";
    flake = false;
  };
}
