rec {
  ableArcherKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINC3vA0PnFXyFRgitP7U8PL+SlTvqvE6eY73rpW5Rj4y";
  ableArcherHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPJsMyzBbL2f0ZgOE7Uw48aIT6CUwaT4yf4hbfx1lrMF";
  steadfastDefenderKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdbnGeKGi8xQ4v8EovF15LSlZ0FuU4IeL+u/96TIgHZ";
  steadfastNoonHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBtTfN1JOki9MUzxZTZ3iKmvRf/9lCvyyL3dV0vxLqww";

  ableArcherKeys = [
    ableArcherKey
    ableArcherHostKey
  ];

  allKeys = [
    ableArcherKey
    ableArcherHostKey
    steadfastNoonHostKey
  ];
}
