{
  git-hooks.hooks = {
    alejandra.enable = true;
    deadnix.enable = true;
    flake-checker.enable = true;
    my-flake-checker = {
      enable = true;
      entry = "nix flake check";
      pass_filenames = false;
    };
  };
}
