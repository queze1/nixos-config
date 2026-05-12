let
  utmVM = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINC3vA0PnFXyFRgitP7U8PL+SlTvqvE6eY73rpW5Rj4y queze@utm-vm";
  utmVMHost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILwEJEmONyS7KjPYVpwTWuokUn5a6mAqjXLmPRaf5JUY root@utm-vm";
in
{
  "queze-password.age" = {
    publicKeys = [
      utmVM
      utmVMHost
    ];
    armor = true;
  };
  "tavily-api-key.age" = {
    publicKeys = [
      utmVM
      utmVMHost
    ];
    armor = true;
  };
}
