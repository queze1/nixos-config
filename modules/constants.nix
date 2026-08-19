{lib, ...}: {
  # Options which all NixOS hosts should have access to.
  options.my.constants.tailnetDomain = lib.mkOption {
    type = lib.types.str;
    default = "tail8963fb.ts.net";
    description = "Tailnet DNS name.";
  };
}
