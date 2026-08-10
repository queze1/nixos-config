{
  flake.homeModules.bitwardenClient = {pkgs, ...}: {
    home.packages = with pkgs; [
      bitwarden-desktop
      bitwarden-cli
    ];

    my.home.preservation.extraDirectories = [
      ".config/Bitwarden"
      ".config/Bitwarden CLI"
    ];
  };
}
