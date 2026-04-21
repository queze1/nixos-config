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
    foot = {
      enable = true;
      settings = {
        main = {
          shell = "${pkgs.fish}/bin/fish";
          font = "Liberation Mono:size=12";
        };
      };
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [ "foot.desktop" ];
    };
  };

  home.shellAliases = {
    nrs = "sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild switch";
    nrb = "sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild boot";
    # Not portable at all, fix sometime
    noctalia-export = "noctalia-shell ipc call state all | nix run nixpkgs#jq .settings > ~/etc/nixos/home/modules/desktop/noctalia.json";
    build-nix-on-droid = "cd ~/etc/nixos && nix flake update nix-on-droid-repo && git add . && git commit -m 'chore: update flake' && git push && sudo --preserve-env=SSH_AUTH_SOCK nixos-rebuild switch && nix run github:serokell/deploy-rs -- --targets '.#nix-on-droid-server' -- --impure";
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
