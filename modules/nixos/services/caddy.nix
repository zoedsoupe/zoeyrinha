# caddy: tailnet-facing reverse proxy for yby services.
# plain HTTP on purpose: the tailnet is wireguard-encrypted end to end,
# TLS inside it buys nothing until a service goes public.
# TODO: replace example.com domains; point DNS (split-horizon in headscale)
# to yby's tailscale IP.
{...}: {
  services.caddy = {
    enable = true;
    virtualHosts."http://cloud.example.com".extraConfig = "reverse_proxy 127.0.0.1:8080";
  };

  # caddy binds every interface, so the firewall is what keeps it tailnet-only.
  # anytype clients hit the sync node directly (33010+), no vhost needed.
  # only reachable from the tailnet
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [80];
}
