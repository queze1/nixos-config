{
  perSystem = {inputs', ...}: {
    myPackages.actions-languageserver = inputs'.nixpkgs-actions-languageserver.legacyPackages.actions-languageserver;
  };
}
