# Grafana, the query UI over loki. tailnet-only behind caddy (http://logs.eveo).
# loki is provisioned as the default datasource so the UI is useful on first
# login, no manual setup.
#
# the admin password and secret_key use grafana's file provider, and the files
# are created by tmpfiles already owned by the grafana user (a static user, so
# tmpfiles runs after sysusers). fill them once, as root, after a rebuild:
#   printf '%s\n' "$(openssl rand -base64 18)" \
#     | sudo tee /etc/grafana/admin-password > /dev/null
#   printf '%s\n' "$(openssl rand -hex 32)" \
#     | sudo tee /etc/grafana/secret-key > /dev/null
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.grafana;
in {
  options.grafana = {
    enable = mkEnableOption "Grafana, the log query UI over loki";

    port = mkOption {
      type = types.port;
      default = 3002;
      description = "Loopback port the Grafana web UI listens on.";
    };

    lokiUrl = mkOption {
      type = types.str;
      default = "http://127.0.0.1:3100";
      description = "Loki base URL for the provisioned datasource.";
    };

    adminPasswordFile = mkOption {
      type = types.path;
      default = "/etc/grafana/admin-password";
      description = "File holding the admin password, owned by the grafana user (tmpfiles).";
    };

    secretKeyFile = mkOption {
      type = types.path;
      default = "/etc/grafana/secret-key";
      description = "File holding Grafana's secret_key (encrypts datasource secrets), owned by the grafana user.";
    };
  };

  config = mkIf cfg.enable {
    services.grafana = {
      enable = true;

      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = cfg.port;
        };
        # the file provider keeps both secrets out of the nix store
        security = {
          admin_password = "$__file{${cfg.adminPasswordFile}}";
          secret_key = "$__file{${cfg.secretKeyFile}}";
        };
      };

      provision.datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = cfg.lokiUrl;
            isDefault = true;
          }
        ];
      };
    };

    # own the files up front so no chown is needed; the grafana user is static
    # and tmpfiles runs after sysusers, so this works before first start
    systemd.tmpfiles.rules = [
      "d /etc/grafana 0750 root grafana -"
      "f ${cfg.adminPasswordFile} 0600 grafana grafana -"
      "f ${cfg.secretKeyFile} 0600 grafana grafana -"
    ];
  };
}
