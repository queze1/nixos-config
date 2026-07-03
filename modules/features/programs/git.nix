{
  flake.homeModules.git = {config, ...}: {
    programs.git = {
      enable = true;
      signing = {
        key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        signByDefault = true;
        format = "ssh";
      };

      settings = {
        user.name = "queze1";
        user.email = "52340127+queze1@users.noreply.github.com";

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
  };
}
