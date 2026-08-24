{
  config,
  lib,
  options,
  ...
}: let
  appsWithPorts = lib.filterAttrs (_: app: app ? port) options.my.apps;
  portAssignments = lib.imap0 (
    index: name:
      lib.setAttrByPath ["my" "apps" name "port"] (lib.mkDefault (8000 + index))
  ) (builtins.attrNames appsWithPorts);
in {
  options.my.apps.autoAssignPorts = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Automatically assign ports in increasing order for hosted services.";
  };

  config = lib.mkIf config.my.apps.autoAssignPorts (lib.mkMerge portAssignments);
}
