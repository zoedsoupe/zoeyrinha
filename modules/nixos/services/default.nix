# every service module is imported on every nixos host; each one is gated
# behind its own `enable` option
{...}: {
  imports = [
    ./caddy.nix
    ./cloudflared.nix
    ./forgejo.nix
    ./glances.nix
    ./nextcloud.nix
    ./phoenix-app.nix
    ./postgresql.nix
    ./uptime-kuma.nix
  ];
}
