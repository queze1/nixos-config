{self, ...}: {
  flake.nixosModules.sharedModules = {
    imports = [
      self.nixosModules.boot
      self.nixosModules.localisation
      self.nixosModules.nix
    ];

    config = {
      networking.nftables.enable = true;

      # Set Vim as default editor
      environment.variables = {
        EDITOR = "vim";
        VISUAL = "vim";
      };

      programs.git = {
        enable = true;
        config = {
          init.defaultBranch = "main";
          push = {
            autoSetupRemote = "true";
          };
          alias = {
            ca = "commit -a --amend";
            cm = "commit -m";
            co = "checkout";
            s = "status";
          };
        };
      };

      zramSwap.enable = true;
    };
  };
}
