{
  inputs,
  self,
  ...
}: {
  # Configure Home Manager as a NixOS module
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

  # Declare a user in Home Manager
  flake.factory.homeConfiguration = {username}: {
    home-manager.users.${username} = {
      home.username = username;
      home.homeDirectory = "/home/${username}";
      home.stateVersion = "25.11";
      programs.home-manager.enable = true;
    };
  };
}
