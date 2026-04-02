{
  lib,
  desktop,
  ...
}:

{
  imports =
    lib.optionals desktop.plasma [ ./plasma-manager.nix ]
    ++ lib.optionals desktop.niri [ ./niri.nix ]
    ++ lib.optionals desktop.noctalia [ ./noctalia.nix ];
}
