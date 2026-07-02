{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.noctalia = {
    # Use Noctalia's binary cache
    nix.settings = {
      extra-substituters = ["https://noctalia.cachix.org"];
      extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
    };

    # Stop showing welcome message
    my.preservation.extraUserDirectories = [
      ".cache/noctalia"
    ];

    home-manager.sharedModules = [
      self.homeModules.noctalia
    ];
  };

  flake.homeModules.noctalia = {
    config,
    self,
    ...
  }: let
    settings = builtins.fromJSON (builtins.readFile ./settings.json);
    modifiedSettings =
      settings
      // {
        wallpaper = {
          directory = "${config.xdg.userDirs.pictures}/Wallpapers";
        };
      };
  in {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia-shell = {
      enable = true;
      settings = modifiedSettings;
    };

    home.shellAliases = {
      noctalia-export = "noctalia-shell ipc call state all | nix run nixpkgs#jq .settings > ~/etc/nixos/modules/features/desktop/noctalia/noctalia.json";
    };

    home.file.profilePicture = {
      target = "${config.home.homeDirectory}/.face";
      source = "${self}/assets/pfp.png";
    };

    home.file.".cache/noctalia/wallpapers.json" = {
      text = builtins.toJSON {
        defaultWallpaper = "${self}/assets/laine-chinensy-temptation-v6.png";
      };
    };
  };
}
