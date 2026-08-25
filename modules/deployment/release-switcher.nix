{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.deployment.release-switcher;
in {
  options.my.deployment.release-switcher.enable =
    lib.mkEnableOption "switching to published NixOS releases";

  config = lib.mkIf cfg.enable {
    sops.secrets.github-access-token = {};

    systemd.services.release-switcher = {
      description = "Switch to the latest published NixOS release";
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
      after = [
        "network-online.target"
        "sops-nix.service"
      ];
      path = with pkgs; [
        bash
        curl
        jq
        nix
        nixos-rebuild
      ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "10s";
      };
      script = ''
        set -u

        release_url="https://api.github.com/repos/queze1/nixos-config/releases/latest"
        assets_url="https://api.github.com/repos/queze1/nixos-config/releases/assets"
        cache_url="https://attic.osipol.uk/cache"
        token_file=${lib.escapeShellArg config.sops.secrets.github-access-token.path}
        hostname=${lib.escapeShellArg config.networking.hostName}
        last_store_path="$(readlink -f /run/current-system)"

        while true; do
          temporary_directory="$(mktemp -d)"
          release_file="$temporary_directory/release.json"
          store_paths_file="$temporary_directory/store-paths.json"
          token="$(< "$token_file")"

          if ! curl --fail --silent --show-error \
            --header "Accept: application/vnd.github+json" \
            --header "Authorization: Bearer $token" \
            "$release_url" > "$release_file"; then
            echo "release-switcher: failed to retrieve the latest release" >&2
            rm -rf "$temporary_directory"
            sleep 10
            continue
          fi

          if ! asset_id="$(jq -r 'first(.assets[] | select(.name == "store-paths.json") | .id) // empty' "$release_file")"; then
            echo "release-switcher: failed to parse the latest release" >&2
            rm -rf "$temporary_directory"
            sleep 10
            continue
          fi

          if [ -z "$asset_id" ]; then
            echo "release-switcher: latest release has no store-paths.json asset" >&2
            rm -rf "$temporary_directory"
            sleep 10
            continue
          fi

          if ! curl --fail --silent --show-error --location \
            --header "Accept: application/octet-stream" \
            --header "Authorization: Bearer $token" \
            "$assets_url/$asset_id" > "$store_paths_file"; then
            echo "release-switcher: failed to retrieve store-paths.json" >&2
            rm -rf "$temporary_directory"
            sleep 10
            continue
          fi

          if ! store_path="$(jq -r --arg hostname "$hostname" '.[$hostname] // empty' "$store_paths_file")"; then
            echo "release-switcher: failed to parse store-paths.json" >&2
            rm -rf "$temporary_directory"
            sleep 10
            continue
          fi

          rm -rf "$temporary_directory"

          if [ -z "$store_path" ]; then
            echo "release-switcher: no store path published for $hostname" >&2
          elif [ "$store_path" = "$last_store_path" ]; then
            :
          elif ! nix path-info --recursive "$store_path" --store "$cache_url" > /dev/null; then
            echo "release-switcher: store path is unavailable from Attic: $store_path" >&2
          else
            last_store_path="$store_path"
            if ! nixos-rebuild switch --no-reexec --store-path "$store_path"; then
              echo "release-switcher: failed to switch to $store_path" >&2
            fi
          fi

          sleep 10
        done
      '';
    };
  };
}
