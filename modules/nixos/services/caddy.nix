# tailnet-facing caddy reverse proxy. plain HTTP on purpose: the tailnet is
# wireguard-encrypted end to end, so TLS inside it buys nothing until a
# service goes public.
#
# add a project by mapping a domain to its local upstream:
#   caddy.apps."proj.example.com" = "127.0.0.1:3000";
# and point DNS at the host (split-horizon record in headscale, or a local
# resolver). caddy binds every interface; the firewall keeps it tailnet-only.
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.caddy;
in {
  options.caddy = {
    enable = mkEnableOption "tailnet-facing caddy reverse proxy";

    apps = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = {
        "cloud.example.com" = "127.0.0.1:8080";
        "proj.example.com" = "127.0.0.1:3000";
      };
      description = "Tailnet-only reverse proxies: domain -> upstream address.";
    };

    accessLog = mkOption {
      type = types.bool;
      default = true;
      description = "Emit access logs on every site. They land in the journal, where alloy ships them.";
    };
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      # the http:// scheme keeps caddy off ACME for tailnet-only domains
      virtualHosts = lib.mapAttrs' (domain: upstream:
        lib.nameValuePair "http://${domain}" {
          extraConfig = ''
            ${lib.optionalString cfg.accessLog "log"}
            reverse_proxy ${upstream}
          '';
        })
      cfg.apps;
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [80];
  };
}
