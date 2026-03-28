{ pkgs, ... }:
{
  programs = {
    bash.enable = true;
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };

  home.shellAliases = {
    nrs = "sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild switch";
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
