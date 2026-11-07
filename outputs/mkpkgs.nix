{...}: {
  flake.factory.mkPkgs = {
    nixpkgs,
    system,
  }:
    import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        (_: prev: {
          pythonPackagesExtensions =
            prev.pythonPackagesExtensions
            ++ [
              (_: python-prev: {
                fpdf2 = python-prev.fpdf2.overridePythonAttrs (old: {
                  disabledTests = (old.disabledTests or []) ++ ["test_image_with_explicit_dimensions"];
                });
              })
            ];
        })
      ];
    };
}
