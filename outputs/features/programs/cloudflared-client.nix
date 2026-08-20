{
  flake.homeModules.cloudflaredClient = {pkgs, ...}: {
    home.packages = [pkgs.cloudflared];

    my.home.preservation.extraDirectories = [".cloudflared"];
  };
}
