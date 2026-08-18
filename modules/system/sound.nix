{
  lib,
  config,
  ...
}: let
  cfg = config.my.sound;
in {
  options.my.sound.enable = lib.mkEnableOption "sound";

  config = lib.mkIf cfg.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    my.preservation.extraUserDirectories = [
      ".local/state/wireplumber"
    ];
  };
}
