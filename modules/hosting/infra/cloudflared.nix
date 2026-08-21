{
  config,
  lib,
  ...
}: {
  options.my.cloudflared.enable = lib.mkEnableOption "Cloudflared";

  config = lib.mkIf config.my.cloudflared.enable {
    services.cloudflared.enable = true;
  };
}
