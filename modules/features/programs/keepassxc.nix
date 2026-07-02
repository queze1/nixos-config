{
  flake.homeModules.keepassxc = {pkgs, ...}: {
    home.packages = [pkgs.keepassxc];

    my.home.preservation.extraDirectories = [
      ".cache/keepassxc"
      ".config/keepassxc"
    ];
  };
}
