{
  config,
  lib,
  ...
}: let
  cfg = config.my.nix;
in {
  # Alias nix.gc and nix.settings under my.nix.*
  imports = [
    (lib.mkAliasOptionModule ["my" "nix" "gc"] [
      "nix"
      "gc"
    ])
    (lib.mkAliasOptionModule ["my" "nix" "settings"]
      ["nix" "settings"])
  ];

  options.my.nix = {
    enable = lib.mkEnableOption "Nix flakes and the Nix command";
    binaryCache.enable = lib.mkEnableOption "the personal binary cache";
    replHistory.enable = lib.mkEnableOption "preserving Nix REPL history";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      nix.settings.experimental-features = ["nix-command" "flakes"];
    })
    (lib.mkIf cfg.binaryCache.enable {
      nix.settings = {
        substituters = [
          "https://attic.osipol.uk/cache"
        ];
        trusted-public-keys = [
          "cache:C3spwmruXebNeOwAnYy98JGgTOnos586oMVmkYn/RYg="
        ];
      };
    })
    (lib.mkIf cfg.replHistory.enable {
      my.preservation.extraUserDirectories = [
        ".local/state/nix"
      ];
    })
  ];
}
