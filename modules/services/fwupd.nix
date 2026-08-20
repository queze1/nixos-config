{
  config,
  lib,
  ...
}: let
  cfg = config.my.fwupd;
in {
  options.my.fwupd.enable = lib.mkEnableOption "fwupd";

  config = lib.mkIf cfg.enable {
    services.fwupd.enable = true;

    my.preservation.extraDirectories = ["/var/lib/fwupd"];
  };
}
