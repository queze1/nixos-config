{ inputs, moduleWithSystem, ... }:
{
  flake.nixosModules.agenix = moduleWithSystem (
    # inputs': inputs, but with system preselected
    { inputs', ... }:
    { ... }:
    {
      imports = [ inputs.agenix.nixosModules.default ];
      environment.systemPackages = [ inputs'.agenix.packages.default ];
    }
  );
}
