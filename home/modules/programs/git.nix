{ ... }:
{
  programs.git = {
    enable = true;
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
        undo = "reset --soft HEAD~1";
      };
    };
  };
}
