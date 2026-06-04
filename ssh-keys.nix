rec {
  ableArcher = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINC3vA0PnFXyFRgitP7U8PL+SlTvqvE6eY73rpW5Rj4y";
  ableArcher2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJsMyzBbL2f0ZgOE7Uw48aIT6CUwaT4yf4hbfx1lrMF";
  macHost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHqiypox+hZOZMn9JuRK4Mxr/u66wTAwP2UZRGGcMkV";

  allKeys = [
    ableArcher
    ableArcher2
    macHost
  ];
}
