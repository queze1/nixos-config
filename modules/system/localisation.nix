{
  config,
  lib,
  ...
}: let
  cfg = config.my.localisation;
in {
  options.my.localisation.enable = lib.mkEnableOption "Australian English localisation";

  config = lib.mkIf cfg.enable {
    time.timeZone = "Australia/Sydney";

    i18n.defaultLocale = "en_GB.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_AU.UTF-8";
      LC_IDENTIFICATION = "en_AU.UTF-8";
      LC_MEASUREMENT = "en_AU.UTF-8";
      LC_MONETARY = "en_AU.UTF-8";
      LC_NAME = "en_AU.UTF-8";
      LC_NUMERIC = "en_AU.UTF-8";
      LC_PAPER = "en_AU.UTF-8";
      LC_TELEPHONE = "en_AU.UTF-8";
      LC_TIME = "en_AU.UTF-8";
    };

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    console.keyMap = "us";
  };
}
