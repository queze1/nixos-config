{
  perSystem = {config, ...}: {
    # Merge myPackages into packages
    packages = config.myPackages;
  };
}
