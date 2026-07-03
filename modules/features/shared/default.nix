{
  flake.nixosModules.sharedModules = {
    networking.nftables.enable = true;

    # Set Vim as default editor
    environment.variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };
}
