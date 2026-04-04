{ pkgs, ... }:
{
  programs = {
    bash.enable = true;
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };
    fish.enable = true;
    kitty = {
      enable = true;
      shellIntegration.enableFishIntegration = true;
    };
    yazi.enable = true;
  };

  home.shellAliases = {
    nrs = "sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild switch";
    nrb = "sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild boot";
    # Not portable at all, fix sometime
    noctalia-export = "noctalia-shell ipc call state all | nix run nixpkgs#jq .settings > ~/etc/nixos/home/modules/desktop/noctalia.json";
  };

  home.packages = [
    # nixify: Initialise nix-direnv for shell.nix
    (pkgs.writeShellScriptBin "nixify" ''
      if [ ! -f .envrc ]; then
        echo "use nix" > .envrc
        ${pkgs.direnv}/bin/direnv allow
      elif ! grep -q "use nix" .envrc; then
        echo "use nix" >> .envrc
        ${pkgs.direnv}/bin/direnv allow
      fi
    '')
  ];
}
