# Grafana Loki: the tailnet log store. single binary, filesystem storage (no
# object store to run), 7d retention driven by the compactor. agents (alloy)
# on every host push here; read the logs in grafana.
#
# state (chunks, index, compactor markers) lives in dataDir. on yby point it at
# a zfs dataset so it inherits snapshots; on eveo the default is fine.
{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.loki;
in {
  options.loki = {
    enable = mkEnableOption "Grafana Loki, the tailnet log store";

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/loki";
      description = "Chunks, index and compactor working dir. Give it a zfs dataset on yby.";
    };

    port = mkOption {
      type = types.port;
      default = 3100;
      description = "HTTP port: ingestion (/loki/api/v1/push) and queries.";
    };

    retention = mkOption {
      type = types.str;
      default = "168h";
      description = "How long to keep logs. Applied by the compactor, wired below.";
    };
  };

  config = mkIf cfg.enable {
    services.loki = {
      enable = true;
      inherit (cfg) dataDir;

      # the canonical single-binary filesystem config (loki docs) plus the
      # compactor, which is the only thing that actually deletes old chunks
      configuration = {
        auth_enabled = false;

        server.http_listen_port = cfg.port;

        common = {
          path_prefix = cfg.dataDir;
          replication_factor = 1;
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
        };

        schema_config.configs = [
          {
            from = "2024-04-01";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];

        storage_config.filesystem.directory = "${cfg.dataDir}/chunks";

        limits_config.retention_period = cfg.retention;

        compactor = {
          working_directory = "${cfg.dataDir}/compactor";
          retention_enabled = true;
          delete_request_store = "filesystem";
        };
      };
    };

    # agents on other tailnet hosts push here; never the public ip
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [cfg.port];
  };
}
