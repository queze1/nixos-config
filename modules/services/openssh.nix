{
  config,
  lib,
  ...
}: let
  cfg = config.my.openssh;
in {
  # Alias services.openssh.openFirewall under my.openssh.*
  imports = [
    (lib.mkAliasOptionModule
      ["my" "openssh" "openFirewall"]
      ["services" "openssh" "openFirewall"])
  ];

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
