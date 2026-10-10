# forgejo, a self-hosted git forge. tailnet-only by default: reach it at
# http://<host>:3000, or front it with a caddy.apps entry.
#
# mirrors are set per-repo in the UI (Forgejo is the source of truth, mirrors
# are push copies):
#   -> github:  push mirror, https url + a PAT (repo + workflow scopes)
#   -> tangled: push mirror, ssh url to a knot (git@tangled.org:user.tngl.sh/repo)
#
# stateDir (db + repos + lfs + dumps) is meant to live on its own zfs dataset;
# the host wires that mount, this module only owns the service.
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.forgejo;
in {
  options.forgejo = {
    enable = mkEnableOption "Forgejo, a self-hosted git forge";

    domain = mkOption {
      type = types.str;
      default = "git.yby";
      description = "Domain Forgejo is reached at (tailnet name).";
    };
  };

  config = mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      database.type = "sqlite3";
      lfs.enable = true;
      # daily logical dump into stateDir/dump, on top of zfs snapshots
      dump.enable = true;

      settings = {
        server = {
          DOMAIN = cfg.domain;
          ROOT_URL = "http://${cfg.domain}/";
          HTTP_PORT = 3000;
        };

        service.DISABLE_REGISTRATION = true;

        # plain http on the tailnet; set true if caddy/edge terminates tls
        session.COOKIE_SECURE = false;
      };
    };

    # tailnet-only: reach it at http://<host>:3000
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [3000];
  };
}
