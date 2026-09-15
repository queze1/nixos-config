{
  inputs,
  self,
  ...
}: {
  self.packages = self.myPackages or {};

  perSystem = {pkgs, ...}: {
    packages.creamlinux-installer = import inputs.creamlinux-installer {inherit pkgs;};
  };
}
