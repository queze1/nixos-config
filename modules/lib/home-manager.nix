{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.homeManager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      self.sharedModules.homeManager
    ];
  };

  flake.darwinModules.homeManager = {
    imports = [
      inputs.home-manager.darwinModules.home-manager
      self.sharedModules.homeManager
    ];
  };

  flake.sharedModules.homeManager = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = {
      inherit
        inputs
        self
        ;
    };

    # Import shared options
    home-manager.sharedModules = [self.homeModules.myOptions];

    # Backup with an incrementing number
    home-manager.backupCommand = ''
      filename="$1"
      extension="backup"
      if [ -e "$filename.$extension" ]; then
          count=1
          while [ -e "$filename.$extension.$count" ]; do
              count=$((count + 1))
          done
          mv "$filename" "$filename.$extension.$count"
      else
          mv "$filename" "$filename.$extension"
      fi
    '';
  };
}
