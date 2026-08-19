{
  flake.factory.setXdgUserDirs = {homeDir}: {
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = false;
      download = "${homeDir}/Downloads";
      documents = "${homeDir}/Documents";
      pictures = "${homeDir}/Pictures";
      videos = "${homeDir}/Videos";
      music = "${homeDir}/Music";
    };
  };
}
