{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    myPackages.creamlinux-installer = import inputs.creamlinux-installer {inherit pkgs;};
  };
}
