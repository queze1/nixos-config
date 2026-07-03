{
  flake.homeModules.git = {
    programs.git = {
      enable = true;
      config = {
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
