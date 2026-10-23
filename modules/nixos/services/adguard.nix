# AdGuard Home: the tailnet's DNS resolver and filter. eveo runs the only
# instance; headscale points `dns.nameservers.global` at it, so every node on
# the tailnet resolves through here (magic dns stays on for node names).
#
# records and filter lists are managed in the web UI, not here: mutableSettings
# is on, so the UI owns everything the module does not pin below. add
#   yby, git.yby, dash.yby              -> 100.64.0.2
#   status.eveo, dns.eveo, logs.eveo               -> 100.64.0.1
# under Filters -> DNS rewrites. reach the UI at http://dns.eveo (caddy on
# eveo, tailnet-only).
#
# security: the resolver answers only the tailnet cgnat/ula ranges
# (allowed_clients) and the firewall opens 53 on tailscale0 only, so eveo's
# public ip never answers a query.
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.adguard;
in {
  options.adguard = {
    enable = mkEnableOption "AdGuard Home, the tailnet DNS resolver and filter";

    port = mkOption {
      type = types.port;
      default = 3000;
      description = "Loopback port the AdGuard web UI listens on.";
    };

    dnsBinds = mkOption {
      type = types.listOf types.str;
      default = ["0.0.0.0"];
      description = "Addresses the DNS server binds. The firewall keeps it tailnet-only.";
    };

    upstreams = mkOption {
      type = types.listOf types.str;
      default = ["1.1.1.1" "9.9.9.9"];
      description = "Resolvers for names AdGuard does not own (rewrites).";
    };

    allowedClients = mkOption {
      type = types.listOf types.str;
      default = ["127.0.0.1/32" "::1/128" "100.64.0.0/10" "fd7a:115c:a1e0::/48"];
      description = "CIDRs allowed to query the resolver: loopback plus the tailnet cgnat/ula ranges.";
    };
  };

  config = mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      # the web UI stays on loopback; caddy fronts it on the tailnet
      host = "127.0.0.1";
      inherit (cfg) port;

      # decl-config is merged into AdGuardHome.yaml on every start; keys we do
      # not set here (rewrites, filters) stay as the UI left them
      mutableSettings = true;

      settings = {
        dns = {
          bind_hosts = cfg.dnsBinds;
          upstream_dns = cfg.upstreams;
          fallback_dns = ["1.1.1.1" "9.9.9.9"];
          allowed_clients = cfg.allowedClients;
          # not reachable from the internet, so the anti-amplification limiter
          # only gets in the way (default is 20 qps)
          ratelimit = 0;
        };

        filtering = {
          protection_enabled = true;
          filtering_enabled = true;
        };
      };
    };

    networking.firewall.interfaces.tailscale0 = {
      allowedTCPPorts = [53];
      allowedUDPPorts = [53];
    };
  };
}
