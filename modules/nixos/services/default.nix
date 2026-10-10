# every service module is imported for every nixos host; each one is gated
# behind its own `enable` option, so a host only flips what it wants on.
{...}: {
  imports = [
    ./anytype.nix
    ./caddy.nix
    ./cloudflared.nix
    ./forgejo.nix
    ./glances.nix
    ./nextcloud.nix
    ./postgresql.nix
    ./uptime-kuma.nix
  ];
}
