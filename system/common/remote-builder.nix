{ ... }:
{
  users.users.remotebuild = {
    isSystemUser = true;
    group = "remotebuild";
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKc5qFBtTUoJyj3LGHNOEdoOlpl1jfIE/3pElxH32m54 nix-on-droid@localhost"
    ];
  };

  users.groups.remotebuild = { };

  nix.settings.trusted-users = [
    "remotebuild"
  ];
}
