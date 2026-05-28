rec {
  ableArcher = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINC3vA0PnFXyFRgitP7U8PL+SlTvqvE6eY73rpW5Rj4y";
  ableArcher2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIRyH8xBvp/2S/PPsFFQzparojdD6neqU7wjqoIFEW8I";
  macHost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHqiypox+hZOZMn9JuRK4Mxr/u66wTAwP2UZRGGcMkV";

  allKeys = [
    ableArcher
    ableArcher2
    macHost
  ];
}
