{
  flake.homeModules.obsidian = {pkgs, ...}: {
    home.packages = [pkgs.obsidian];

    my.home.preservation.extraDirectories = [
      ".config/obsidian"
    ];
  };
}
