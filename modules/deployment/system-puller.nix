{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.deployment.system-puller;
in {
  # Pull-based deployment without evaluation
  # GHA builds system toplevels, pushes to a binary cache, and publishes the store path, systemd service polls and applies changes
  options.my.deployment.system-puller.enable =
    lib.mkEnableOption "pulling published NixOS systems";

  config = lib.mkIf cfg.enable {
    sops.secrets.github-access-token = {};

    systemd.services.system-puller = {
      description = "Pull and switch to the latest published NixOS system";
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
      after = [
        "network-online.target"
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
        RuntimeDirectory = "system-puller";
      };
      script = ''
        set -u

        release_url="https://api.github.com/repos/queze1/nixos-config/releases/latest"
        assets_url="https://api.github.com/repos/queze1/nixos-config/releases/assets"
        cache_url="https://attic.osipol.uk/cache"
        token_file=${lib.escapeShellArg config.sops.secrets.github-access-token.path}
        hostname=${lib.escapeShellArg config.networking.hostName}
        runtime_directory="/run/system-puller"
        release_file="$runtime_directory/release.json"
        store_paths_file="$runtime_directory/store-paths.json"
        last_store_path="$(readlink -f /run/current-system)"

        while true; do
          token="$(< "$token_file")"

          if ! curl --fail --silent --show-error \
            --header "Accept: application/vnd.github+json" \
            --header "Authorization: Bearer $token" \
            "$release_url" > "$release_file"; then
            echo "system-puller: failed to retrieve the latest release" >&2
            sleep 10
            continue
          fi

          if ! asset_id="$(jq -r 'first(.assets[] | select(.name == "store-paths.json") | .id) // empty' "$release_file")"; then
            echo "system-puller: failed to parse the latest release" >&2
            sleep 10
            continue
          fi

          if [ -z "$asset_id" ]; then
            echo "system-puller: latest release has no store-paths.json asset" >&2
            sleep 10
            continue
          fi

          if ! curl --fail --silent --show-error --location \
            --header "Accept: application/octet-stream" \
            --header "Authorization: Bearer $token" \
            "$assets_url/$asset_id" > "$store_paths_file"; then
            echo "system-puller: failed to retrieve store-paths.json" >&2
            sleep 10
            continue
          fi

          if ! store_path="$(jq -r --arg hostname "$hostname" '.[$hostname] // empty' "$store_paths_file")"; then
            echo "system-puller: failed to parse store-paths.json" >&2
            sleep 10
            continue
          fi

          if [ -z "$store_path" ]; then
            echo "system-puller: no store path published for $hostname" >&2
          elif [ "$store_path" = "$last_store_path" ]; then
            :
          elif ! nix path-info "$store_path" --store "$cache_url" > /dev/null; then
            echo "system-puller: store path is unavailable from Attic: $store_path" >&2
          else
            last_store_path="$store_path"
            echo "pulling system closure: $store_path"
            nix copy "$store_path"
            if ! nixos-rebuild switch --no-reexec --store-path "$store_path"; then
              echo "system-puller: failed to switch to $store_path" >&2
            fi
          fi

          sleep 10
        done
      '';
    };
  };
}
