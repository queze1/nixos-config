{
  # Merge myPackages into packages
  perSystem = {config, ...}: {
    packages = config.myPackages;
  };
}
