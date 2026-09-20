{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.my.programs.nvf.enable {
    home-manager.sharedModules = [
      ({
        config,
        lib,
        osConfig,
        pkgs,
        ...
      }: let
        hostName = osConfig.networking.hostName;
        flakePath = "${config.home.homeDirectory}/etc/nixos";
      in {
        programs.nvf.settings.vim.lsp.servers.nixd = {
          settings = {
            nixd = {
              nixpkgs = {
                expr = "import (builtins.getFlake \"${flakePath}\").inputs.nixpkgs {}";
              };
              formatting = {
                command = ["${lib.getExe pkgs.alejandra}"];
              };
              options = {
                nixos = {
                  expr = "(builtins.getFlake \"${flakePath}\").nixosConfigurations.${hostName}.options";
                };
                home_manager = {
                  expr = "(builtins.getFlake \"${flakePath}\").nixosConfigurations.${hostName}.options.home-manager.users.type.getSubOptions []";
                };
                flake_parts = {
                  expr = "(builtins.getFlake \"${flakePath}\").debug.options";
                };
                flake_parts2 = {
                  expr = "(builtins.getFlake \"${flakePath}\").currentSystem.options";
                };
              };
            };
          };
        };
      })
    ];
  };
}
