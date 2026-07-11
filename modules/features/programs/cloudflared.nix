{
  flake.homeModules.cloudflared = {pkgs, ...}: {
    home.packages = [pkgs.cloudflared];

    my.home.preservation.extraDirectories = [".cloudflared"];
  };
}
