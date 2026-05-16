{ self, inputs, ... }:
{
  flake.nixosModules.minimalSystem = {
    imports = [
      # Allow use of home-manager inside NixOS modules
      # E.g. home-manager.sharedModules
      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.agenix
      self.nixosModules.disko
      self.nixosModules.preservation
    ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit inputs; };

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
