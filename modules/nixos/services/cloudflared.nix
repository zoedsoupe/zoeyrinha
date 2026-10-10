# cloudflare tunnel: public ingress for selected apps without opening any
# inbound port or exposing the home ip (works behind cgnat).
#
# cloudflare terminates tls, so it can read the traffic: only point public,
# non-sensitive services here. for identity-bearing services (like a pds) the
# traffic is public anyway, but home uptime becomes their uptime.
#
# provision once (on any machine, out of band):
#   cloudflared tunnel login
#   cloudflared tunnel create yby
#   install -m 600 ~/.cloudflared/<uuid>.json /var/lib/cloudflared/credentials.json
#   cloudflared tunnel route dns yby <hostname>
# then fill cloudflared.apps below and rebuild.
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.cloudflared;
in {
  options.cloudflared = {
    enable = mkEnableOption "cloudflare tunnel for selected public apps";

    tunnel = mkOption {
      type = types.str;
      default = "yby";
      description = "Tunnel name, as created with `cloudflared tunnel create`.";
    };

    credentialsFile = mkOption {
      type = types.path;
      default = "/var/lib/cloudflared/credentials.json";
      description = "Tunnel credentials json, provisioned out of band.";
    };

    apps = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = {"pds.example.com" = "http://localhost:4000";};
      description = "Public hostname -> origin URL.";
    };
  };

  config = mkIf cfg.enable {
    services.cloudflared = {
      enable = true;
      tunnels.${cfg.tunnel} = {
        credentialsFile = cfg.credentialsFile;
        default = "http_status:404";
        ingress = cfg.apps;
      };
    };
  };
}
