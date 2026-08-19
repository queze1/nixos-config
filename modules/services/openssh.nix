{
  config,
  lib,
  ...
}: let
  cfg = config.my.openssh;
in {
  options.my.openssh.enable = lib.mkEnableOption "OpenSSH";

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };

      # Don't ban my Tailscale devices
      extraConfig = ''
        PerSourcePenaltyExemptList 100.64.0.0/10
      '';
    };
  };
}
