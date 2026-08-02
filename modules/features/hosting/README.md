# WIP DOCS
Most services are intended to be private.
This means they should only allow the path:
1. I (i.e. my machine, on my Tailnet) go to a human-readable HTTPS url.
2. Service authenticates me and responds.

In practice, steps look like:
1. Cloudflare DNS (e.g. [yubal.osipol.uk/](https://yubal.osipol.uk/)) points to a Tailscale IP (e.g. 100.68.90.10).
  - `ddns.nix` keeps the DNS record pointing to the machine running the service.
  - Caddy Cloudflare DNS plugin handles DNS chalenge.
  - Clients attempting to access the URL from the public internet are blocked here.
2. Client attempts to access the host, typically on port 443.
  - Ports 80, 443 and 8443 are open only on Tailscale, blocking connections from LAN.
  - Tailscale ACL is configured to block all access from devices not in `autogroup:owner` (i.e. my laptop and 2 phones) by default (with exceptions, e.g. port 8443 is whitelisted so services which need to be accessible by servers can use that port). 
3. Caddy authenticates incoming requests and redirects them to the correct service.
  - No service ports are opened (e.g. `8000`), since clients should not be able to bypass Caddy.
  - To prevent local processes from bypassing Caddy, Unix sockets are used wherever possible, but where they are not, a firewall in `caddy.nix` is used to block outgoing connections to service ports, unless they are from the Caddy user.
  - Services which servers do not need to access use `tailscale-nginx-auth` for authentication.
    - NOTE: `tailscale-nginx-auth` automatically blocks tagged devices, so this cannot be used for services such as `rest-server`, which servers access.
4. Service receives the request and responds.

A "typical" private service looks like:
1. Service definition from nixpkgs (e.g. `services.actual = {}`).
  - This is usually a wrapper around a hardened systemd service.
  - Alternatively, a rootless Podman container may be used for Docker applications.
2. File access wrangling, such as:
  - Preserving application data with `preservation` with correct permissions.
  - Initialising directories with `tmpfiles` if the service definition didn't do this if you.
  - Creating a system user and group to run Podman containers or manage file permissions.
    - See [github.com/podman-container-tools/podman/blob/main/docs/tutorials/rootless_tutorial.md](https://github.com/podman-container-tools/podman/blob/main/docs/tutorials/rootless_tutorial.md) for info on user management with rootless Podman.
3. Configuring any needed secrets with `sops-nix`.
  - Ideally, the service definition should allow passing secrets as file paths.
  - If that isn't possible, you may need to manually set `EnvironmentFile` on the systemd service and define your secrets as environment variables.
4. Backup configuration with `restic`
  - I use a custom module which defines helper options at `my.restic` (e.g. `my.restic.extraPaths`, adds those paths to all backup locations).
  - Configure the service to perform regular backup dumps if they support it (for ease of restoration).
5. Networking
  - Give Caddy access to the service's Unix socket OR firewall the service port so only Caddy can access it.
  - Define a new host which points to the service with Cloudflare DNS and (optionally) `tailscale-nginx-auth`.
  - Add the domain to `ddclient`.

# Overview
- Actual Budget 
- Ark RP Visualisation - Public service, uses Cloudflare Tunnel.
- Garage - Unused.
- Music services - All use `music` group to share access to `/srv/music`
  - Navidrome 
  - MeTube - Uses rootless Podman container.
  - Yubal - Uses rootless Podman container.
  - Picard (on Docker)  - Uses rootless Podman container.
- Pi-Hole - Opens port 53 on Tailscale for DNS. Runs custom backup script daily to dump Teleporter backup. No `tailsale-nginx-auth` (server needs to access itself).
- rest-server - Runs on port 8443 (whitelisted by Tailscale ACL). Runs in append-only mode.
- SillyTavern


