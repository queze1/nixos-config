{ ... }:
{
  users.users.remotebuild = {
    isSystemUser = true;
    group = "remotebuild";
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODW/QqzVUEST/Ig01af/IkKrNz1PAOKQYq1E8eOB5O0 nix-on-droid@localhost"
    ];
  };

  users.groups.remotebuild = { };

  nix.settings.trusted-users = [
    "remotebuild"
  ];
}
