{ inputs, moduleWithSystem, ... }:
{
  flake.nixosModules.agenix = moduleWithSystem (
    { inputs', ... }:
    { ... }:
    {
      imports = [ inputs.agenix.nixosModules.default ];
      environment.systemPackages = [ inputs'.agenix.packages.default ];
    }
  );
}
