# every service module is imported on every nixos host; each one is gated
# behind its own `enable` option
{...}: {
  imports = [
    ./adguard.nix
    ./alloy.nix
    ./caddy.nix
    ./cloudflared.nix
    ./docker.nix
    ./forgejo.nix
    ./gatus.nix
    ./glances.nix
    ./grafana.nix
    ./loki.nix
    ./nextcloud.nix
    ./phoenix-app.nix
    ./postgresql.nix
  ];
}
