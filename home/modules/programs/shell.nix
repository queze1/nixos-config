{ pkgs, ... }:
{
  programs = {
    bash.enable = true;
    fish.enable = true;
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };
    kitty = {
      enable = true;
      shellIntegration.enableBashIntegration = true;
      shellIntegration.enableFishIntegration = true;
      themeFile = "rose-pine-dawn";
      settings = {
        # Use fish instead of bash by default
        shell = "${pkgs.fish}/bin/fish";
      };
    };
  };

  home.shellAliases = {
    nrs = "sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild switch";
    nrb = "sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild boot";
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
