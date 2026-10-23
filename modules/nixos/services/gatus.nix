# Gatus: declarative uptime checks and a status page.
# one endpoint per check; conditions are gatus expressions
# ([STATUS] == 200, [BODY]..., [RESPONSE_TIME] < ...).
#
# tailnet-only: it binds loopback behind caddy (http://status.eveo). checks on
# *.yby resolve through adguard (the tailnet's dns) and go out over the
# tailnet, so from eveo they exercise the real path a client takes.
#
# email alerts: set `gatus.email`, then one secret file, mode 600 root:root
# (systemd reads EnvironmentFile before dropping privileges):
#   sudo install -d -m 750 /etc/gatus
#   printf 'GATUS_SMTP_PASSWORD=%s\n' '<app-specific-password>' \
#     | sudo tee /etc/gatus/gatus.env > /dev/null
#   sudo chmod 600 /etc/gatus/gatus.env
# for icloud mail that password is an app-specific one (appleid -> sign-in &
# security -> app-specific passwords); a plain appleid password will not work.
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.gatus;

  # every endpoint alerts by email unless it opts out with its own list
  defaultAlerts = lib.optional (cfg.email != null) {type = "email";};

  emailProvider = {
    inherit (cfg.email) host port to;
    # icloud: username is the address, only the password is a secret
    from =
      if cfg.email.from != null
      then cfg.email.from
      else cfg.email.to;
    username =
      if cfg.email.from != null
      then cfg.email.from
      else cfg.email.to;
    password = "\${GATUS_SMTP_PASSWORD}";
    default-alert = {
      enabled = true;
      failure-threshold = cfg.email.failureThreshold;
      success-threshold = cfg.email.successThreshold;
      send-on-resolved = cfg.email.sendOnResolved;
      description = cfg.email.description;
    };
  };
in {
  options.gatus = {
    enable = mkEnableOption "Gatus, declarative uptime checks and a status page";

    port = mkOption {
      type = types.port;
      default = 3001;
      description = "Loopback port the Gatus web UI/API listens on. 8080 is headscale's on eveo.";
    };

    endpoints = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Name shown on the status page.";
          };
          url = mkOption {
            type = types.str;
            description = "URL to check.";
          };
          group = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Status page group, e.g. the host the service runs on.";
          };
          interval = mkOption {
            type = types.str;
            default = "5m";
            description = "How often to check.";
          };
          conditions = mkOption {
            type = types.listOf types.str;
            default = ["[STATUS] == 200"];
            description = "Gatus conditions that decide success.";
          };
          alerts = mkOption {
            type = types.listOf types.attrs;
            default = [];
            description = "Per-endpoint alert rules. Empty means the email default (when email is on).";
          };
        };
      });
      default = [];
      description = "Uptime checks; each becomes a Gatus endpoint.";
    };

    email = mkOption {
      type = types.nullOr (types.submodule {
        options = {
          to = mkOption {
            type = types.str;
            default = "zoey.spessanha@icloud.com";
            description = "Recipient (comma-separated for several).";
          };
          from = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Sender address. null uses `to` (the icloud case).";
          };
          host = mkOption {
            type = types.str;
            default = "smtp.mail.me.com";
            description = "SMTP relay host.";
          };
          port = mkOption {
            type = types.port;
            default = 587;
            description = "SMTP relay port.";
          };
          failureThreshold = mkOption {
            type = types.ints.positive;
            default = 3;
            description = "Consecutive failures before alerting.";
          };
          successThreshold = mkOption {
            type = types.ints.positive;
            default = 3;
            description = "Consecutive successes before resolving.";
          };
          sendOnResolved = mkOption {
            type = types.bool;
            default = true;
            description = "Send a notification when an alert resolves.";
          };
          description = mkOption {
            type = types.str;
            default = "health check failed";
            description = "Alert description included in the email.";
          };
        };
      });
      default = null;
      description = "Enable email alerts. Requires the GATUS_SMTP_PASSWORD env file (see the module header).";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = "/etc/gatus/gatus.env";
      description = "File with GATUS_SMTP_PASSWORD, read by systemd.";
    };

    alerting = mkOption {
      type = types.attrs;
      default = {};
      description = "Extra Gatus alerting providers, merged with the email provider.";
    };
  };

  config = mkIf cfg.enable {
    services.gatus = {
      enable = true;
      environmentFile = lib.mkIf (cfg.email != null) cfg.environmentFile;

      settings = {
        web = {
          address = "127.0.0.1";
          inherit (cfg) port;
        };

        # gatus' compiled default is /data/data.db, which does not exist;
        # pin it at the service's state dir instead
        storage = {
          type = "sqlite";
          path = "/var/lib/gatus/data.db";
        };

        endpoints = map (endpoint:
          lib.filterAttrs (_: value: value != null) {
            inherit (endpoint) name url group interval conditions;
            alerts =
              if endpoint.alerts != []
              then endpoint.alerts
              else defaultAlerts;
          })
        cfg.endpoints;

        alerting =
          lib.recursiveUpdate cfg.alerting
          (lib.optionalAttrs (cfg.email != null) {email = emailProvider;});
      };
    };
  };
}
