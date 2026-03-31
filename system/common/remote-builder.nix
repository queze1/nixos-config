{ ... }:
{
  users.users.remotebuild = {
    isSystemUser = true;
    group = "remotebuild";
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyBFW1zSqRc+mDz9qyzpRaUamys8KzAwTqfVv66FEbH nix-on-droid@localhost"
    ];
  };

  users.groups.remotebuild = { };

  nix.settings.trusted-users = [
    "remotebuild"
  ];
}
