{
  inputs,
  pkgs,
  ...
}: {
  perSystem = {config, ...}: {
    # Merge myPackages into packages
    packages = config.myPackages;

    myPackages.creamlinux-installer = import inputs.creamlinux-installer {inherit pkgs;};
  };
}
