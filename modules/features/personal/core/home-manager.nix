{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.homeManager = {pkgs-stable, ...}: {
    imports = [
      # Allow Home Manager options in NixOS
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = {
      inherit
        inputs
        pkgs-stable
        self
        ;
    };

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

    # Import helper modules in /shared (which does not include Home Manager)
    home-manager.sharedModules = [
      self.homeModules.xdgUserDirs
    ];
  };
}
