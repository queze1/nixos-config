{ self, ... }:
{
  flake.nixosModules.hostOptions =
    {
      config,
      ...
    }:
    { };
}
