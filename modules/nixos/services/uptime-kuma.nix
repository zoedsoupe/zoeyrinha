# uptime-kuma, up/down checks with notifications and a status page. tailnet-only:
# it binds loopback, caddy fronts it, so reach it at
#   caddy.apps."status.yby" = "127.0.0.1:3001";
# state (sqlite + history) lives in /var/lib/uptime-kuma; the host wires the zfs
# dataset there, this module only owns the service.
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.uptime-kuma;
in {
  options.uptime-kuma = {
    enable = mkEnableOption "Uptime Kuma, a self-hosted uptime monitor";

    port = mkOption {
      type = types.port;
      default = 3001;
      description = "Loopback port the uptime-kuma server listens on.";
    };

    appriseSupport = mkOption {
      type = types.bool;
      default = false;
      description = "Bundle the apprise CLI, unlocking ~100 extra notification providers.";
    };
  };

  config = mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      inherit (cfg) appriseSupport;
      settings = {
        HOST = "127.0.0.1";
        PORT = toString cfg.port;
      };
    };
  };
}
