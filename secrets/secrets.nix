let
  ableArcher = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINC3vA0PnFXyFRgitP7U8PL+SlTvqvE6eY73rpW5Rj4y";
  macHost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILwEJEmONyS7KjPYVpwTWuokUn5a6mAqjXLmPRaf5JUY";
in
{
  "queze-password.age" = {
    publicKeys = [
      ableArcher
      macHost
    ];
    armor = true;
  };
  "tavily-api-key.age" = {
    publicKeys = [
      ableArcher
      macHost
    ];
    armor = true;
  };
}
